# Zone Clock 1.0 — Quick Start

A KDE Plasma system tray widget for tracking multiple world timezones. Full details live in [README.md](README.md); this is the condensed version.

## Install (Fedora KDE)

```bash
cd plasmoid
./install.sh
```

That installs dependencies, builds with CMake, and installs the widget. To do it by hand instead:

```bash
sudo dnf install -y cmake extra-cmake-modules kf6-ki18n-devel kf6-kpackage-devel \
  kf6-kcoreaddons-devel qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtsvg-devel

mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make -j$(nproc)
sudo make install
```

## Activate

```bash
systemctl --user restart plasma-plasmashell
```

Then: right-click your panel → **Add Widgets** → search **"Zone Clock"** → add it.

## Try it without installing

```bash
cd plasmoid
plasmoidviewer -a . zone-clock
```

## First timezone

1. Click the globe icon → **Add Timezone**
2. Name it (e.g. "Tokyo")
3. Pick **UTC Offset** (fixed, no daylight saving) or **Country / City** (real timezone, daylight saving handled automatically) and choose the value
4. Pick 12-hour or 24-hour, and whether to show seconds
5. Click **Add**

Add a second one and a drag-handle (≡) appears on each row for reordering.

## Storage

Saved automatically through Plasma's own applet configuration — no manual file editing.

## Troubleshooting

- **Widget missing after install** → fully restart Plasma: `systemctl --user restart plasma-plasmashell`
- **A clock shows "Invalid TZ"** → only affects Country/City clocks whose id your system's Qt build can't resolve; switch that entry to UTC Offset mode
- **Need a city that's not listed** → add it to `ianaZones` in `contents/ui/TimezoneData.js` (see README's Development section)
