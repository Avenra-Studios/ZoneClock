# Zone Clock 1.0 — Developer Notes

Internal notes on how the widget is put together. For install/usage, see [README.md](README.md) or [QUICKSTART.md](QUICKSTART.md).

## Architecture

```
main.qml (PlasmoidItem)
├─ compactRepresentation      world icon in the tray, toggles the popup
├─ fullRepresentation          popup: heading, scrollable list, "Add Timezone" button
│  └─ Repeater → TimezoneDelegateItem  (one per saved clock)
├─ AddTimezoneDialog (×2: one reused for "Add", one reused for "Edit")
└─ syncTimeFromNetwork()       periodic clock-drift correction (see below)

TimezoneDelegateItem.qml       one row: name, subtitle, live time, edit/delete buttons
AddTimezoneDialog.qml          the add/edit form
TimezoneModel.qml              ListModel wrapping TimezoneData.zones (UTC-offset picker)
CountryTimezoneModel.qml       ListModel wrapping TimezoneData.ianaZones (country/city picker)
TimezoneData.js                single source of truth: zone lists + time formatting
```

## Two timezone modes

Each saved clock has a `mode` field, `"offset"` or `"iana"`:

- **`offset`** — a fixed UTC offset, computed with plain date arithmetic in `TimezoneData.formatTimeOffset()`. No dependency on the JS engine's timezone database, so it cannot fail — this is the reliable fallback.
- **`iana`** — a real IANA timezone id, with daylight saving applied automatically for cities that observe it. This does *not* use `Intl.DateTimeFormat`'s `timeZone` option — that's the normal way to do this in JavaScript, but Plasma's QML JS engine frequently lacks the ICU timezone database it depends on, and throws for every id, valid ones included, rather than just unrecognized ones (this used to make Country/City mode show "Invalid TZ" unconditionally on affected systems). Instead, `TimezoneData.js` carries each curated zone's own standard UTC offset plus a small set of DST rules (`DST_RULES`, plus a special case for Israel) and computes the correct offset itself with plain date arithmetic — see the file-level comment there for details, and `formatTimeIana()` still fails safe to "Invalid TZ" for a genuinely unrecognized id (e.g. one saved by a version of the widget with a longer zone list than the current one).

Entries saved before this option existed have no `mode` field at all — `main.qml` and `AddTimezoneDialog.qml` both treat a missing/unrecognized mode as `"offset"`, matching the old UTC-offset-only behavior.

## Network time sync

`main.qml` periodically issues a plain HTTPS `HEAD` request and reads the response's `Date` header, rather than calling a dedicated time API, so the feature doesn't depend on any one third-party service staying up. The difference between that header and the local clock is stored in `timeOffsetMillis` and applied to every clock's "now". It defaults to 0 (falls back to the local system clock) until a sync succeeds, so the widget works fully offline — it just trusts the local clock in that case. Re-synced every 30 minutes in case the widget stays open a long time.

## Data storage

Persisted as a JSON array under the `timezones` key defined in `contents/config/main.xml`, using Plasma's normal applet-configuration mechanism (`plasmoid.configuration.timezones`) — the same as any other widget's settings.

## A QML gotcha worth knowing about

`AddTimezoneDialog` is instantiated once for "Add" and once for "Edit", and each instance is reused across multiple operations. Its `RadioButton`/`CheckBox` controls originally bound `checked` declaratively to a `dialog.*` property (e.g. `checked: dialog.mode === "offset"`) — but QML permanently severs that binding the first time the user interacts with the control. After that, changing `dialog.mode` (or `.format24h`, `.showSeconds`) programmatically — e.g. resetting the Add dialog, or loading a different entry into the Edit dialog — silently stopped updating the control's visual state, even though the underlying value was correct. `onVisibleChanged` now explicitly re-applies every field (and restores the bindings with `Qt.binding()`) each time the dialog opens, rather than relying on bindings that may already be broken.

## Customizing

**Add more country/city entries**: edit `ianaZones` in `contents/ui/TimezoneData.js`.
**Change the tray icon**: edit `Icon` in `metadata.json`.
**Theming**: components use `Kirigami.Theme.*`, so they follow the system color scheme automatically (the dialog's own background is intentionally fixed dark for readability against arbitrary panel themes).

## Requirements

Plasma 6, Qt 6.5+, KDE Frameworks 6.0+. No dependencies beyond KDE/Qt.
