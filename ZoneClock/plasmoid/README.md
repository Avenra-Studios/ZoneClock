# Zone Clock - KDE Plasmoid

A system tray widget for managing multiple world timezones in KDE Plasma.

## Features

- 🌍 Manage multiple timezones at once
- 🎨 Display in system tray with world icon
- ⏰ Real-time updates with 12/24 hour format options
- ✏️ Edit or delete timezone entries
- 📍 Drag to reorder timezones
- 💾 Automatic persistent storage

## Installation

### Prerequisites

For Fedora KDE:
```bash
sudo dnf install plasma-framework-devel cmake extra-cmake-modules kf6-ki18n-devel
```

### Build and Install

```bash
cd plasmoid
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$(kf6-config --prefix) ..
make
make install
```

### Restart Plasma

After installation, restart Plasma Shell:
```bash
killall plasmashell
# Plasma will auto-restart after a few seconds
# Or manually:
kstart5 plasmashell &
```

### Add to Panel

1. Right-click on your panel
2. Select "Enter Edit Mode"
3. Click "Add Widgets"
4. Search for "Zone Clock"
5. Click it to add to your panel

## Usage

### Adding a Timezone

1. Click the world icon in the system tray
2. Click the "+ Add Timezone" button
3. Enter a display name (e.g., "My Office", "Tokyo", "Home")
4. Select the timezone from the dropdown (searchable)
5. Choose your preferred time format (12-hour or 24-hour)
6. Click "Ok"

### Managing Timezones

- **Edit**: Click the pencil icon on any timezone entry
- **Delete**: Click the trash icon on any timezone entry
- **Reorder**: When 2+ timezones exist, click the drag handle (≡) to access move options

### Time Display

- Times update automatically every second
- All times are displayed in the selected format
- Invalid timezones show "Invalid TZ" (double-check timezone spelling)

## Configuration Files

User data is stored in:
```
~/.config/plasmoidviewer2rc (when testing)
~/.config/plasmarc (production)
```

## Troubleshooting

**Widget doesn't appear after installation:**
- Ensure CMake found correct KDE installation: `kf6-config --prefix`
- Restart Plasma Shell completely

**Times don't update:**
- Check browser console (F12) for JavaScript errors
- Verify timezone names are valid IANA timezone identifiers

**Can't find timezone in dropdown:**
- The dropdown is searchable - type the name
- Use standard IANA format: "America/New_York", "Asia/Tokyo", etc.

## Development

To test during development:
```bash
cd plasmoid
plasmoidviewer -a . zone-clock
```

## License

GPL-3.0
