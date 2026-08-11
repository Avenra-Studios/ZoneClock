# Zone Clock 1.0 — KDE Plasmoid

A system tray widget for tracking multiple world timezones in KDE Plasma 6.

## Features

- 🌍 Track any number of clocks at once, each with a custom display name
- 🕒 Two independent modes per clock:
  - **UTC Offset** — a fixed offset (e.g. `UTC+2`) that never changes, by definition, for daylight saving
  - **Country / City** — a real IANA timezone (e.g. `Asia/Tokyo`) that adjusts for daylight saving automatically
- ⏰ Per-clock 12-hour / 24-hour format, and an option to show or hide seconds
- ✏️ Edit or delete any entry
- 📍 Reorder clocks (Move Up / Move Down) once 2 or more are added
- 🌐 Corrects for local clock drift by periodically checking a network time source, so displayed times stay accurate even if the system clock is off
- 💾 Saved automatically through Plasma's own applet configuration — nothing to configure by hand

## Installation

### Prerequisites (Fedora KDE)

```bash
sudo dnf install -y \
    cmake make gcc gcc-c++ pkg-config extra-cmake-modules \
    kf6-ki18n-devel kf6-kpackage-devel kf6-kcoreaddons-devel \
    qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtsvg-devel
```

(On other distros, install the equivalent Qt 6.5+ / KDE Frameworks 6.0+ development packages.)

### Build and install

```bash
cd plasmoid
./install.sh
```

This runs the dependency check, configures and builds with CMake, and installs the plasmoid — see [`install.sh`](install.sh) for the exact steps if you'd rather run them by hand.

Or manually:
```bash
cd plasmoid
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make -j$(nproc)
sudo make install
```

### Restart Plasma

```bash
systemctl --user restart plasma-plasmashell
# or: plasmashell --replace
```

### Add to panel / system tray

1. Right-click your panel → **Add Widgets**
2. Search for **"Zone Clock"**
3. Click it (or drag it) to add it

## Usage

### Adding a timezone

1. Click the globe icon to open the widget
2. Click **Add Timezone**
3. Enter a display name (e.g. "Home", "Tokyo Office")
4. Choose a type:
   - **UTC Offset** — pick a fixed offset from the list (UTC-12 to UTC+14)
   - **Country / City** — pick a real city; this clock will follow daylight saving automatically
5. Choose 12-hour or 24-hour, and whether to show seconds
6. Click **Add**

### Managing timezones

- **Edit**: pencil icon on any entry
- **Delete**: trash icon on any entry — this is immediate, there's no confirmation prompt
- **Reorder**: once 2+ clocks exist, click the drag-handle (≡) icon on an entry for a Move Up / Move Down menu

### Time display

- Clocks update every second
- A "Country / City" clock shows **Invalid TZ** only if its saved zone id isn't one of the ~80 curated cities in the picker (e.g. an entry saved by a version of the widget with a longer list) — daylight saving for the listed cities is computed directly rather than through the system's timezone database, so it works the same on every machine — a "UTC Offset" clock can never show this, since it's plain arithmetic with no daylight saving to compute

## How data is stored

Your timezone list is saved through Plasma's normal applet-configuration mechanism (the `timezones` key defined in `contents/config/main.xml`), the same way any other widget's settings are saved. It persists automatically across logins and Plasma restarts — there's no separate file to edit or back up by hand.

## Troubleshooting

**Widget doesn't appear after installation**
- Confirm the install actually completed (`sudo make install` should print no errors)
- Fully restart Plasma Shell: `systemctl --user restart plasma-plasmashell`

**A clock shows "Invalid TZ"**
- Only happens in Country/City mode, and only for a zone id outside the curated picker list (see "Development" to add one) — switch that clock to UTC Offset mode as a workaround, or add the city to `ianaZones` in `TimezoneData.js`

**Times all look off by a fixed amount**
- The widget periodically corrects for system clock drift using an HTTPS request's `Date` header; if you're offline, it falls back to your system clock. Check your system clock and network connection.

## Development

To test changes without installing:
```bash
cd plasmoid
plasmoidviewer -a . zone-clock
```

Project layout:
```
plasmoid/
├── metadata.json              ← Plasmoid metadata (id, version, entry point)
├── CMakeLists.txt             ← Build configuration
├── install.sh                 ← Dependency check + build + install
└── contents/
    ├── ui/
    │   ├── main.qml                   ← Tray icon, popup, list, dialogs wiring
    │   ├── TimezoneDelegateItem.qml   ← One clock row (name, time, edit/delete)
    │   ├── AddTimezoneDialog.qml      ← Add/edit form
    │   ├── TimezoneModel.qml          ← UTC-offset picker list
    │   ├── CountryTimezoneModel.qml   ← Country/city picker list
    │   ├── TimezoneData.js            ← Shared zone data + time formatting logic
    │   └── config.qml                 ← Settings page (points back to the main widget)
    └── config/
        ├── config.qml          ← Declares the settings page above
        └── main.xml            ← Config schema (the `timezones` key)
```

## License

GPL-3.0
