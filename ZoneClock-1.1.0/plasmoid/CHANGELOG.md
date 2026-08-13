# Changelog

## Version 1.1.0 — 2026-08-12

### ✨ New Features & Improvements

- **Responsive UI Sizing**: Popup and dialog windows now automatically adapt to your screen resolution
  - Main popup window scales from 70% of screen size (with intelligent min/max bounds)
  - Add/Edit timezone dialog scales adaptively based on available screen space
  - Prevents content from being cut off on ultra-wide, high-resolution, or smaller displays

- **Better Display Scaling**: 
  - Minimum popup size: 32×35 gridUnits (prevents being too small)
  - Maximum popup size: 50×60 gridUnits (prevents being too large)
  - Dialog adapts between 28×28 and 42×55 gridUnits depending on screen

- **Improved Installation Process**:
  - `install.sh` now **auto-detects** and removes old 1.0.0 version
  - New `upgrade.sh` script for **automatic 1-command upgrades**
  - Both scripts preserve your existing timezone configurations
  - Configuration backups are automatically created during upgrade

### 🔧 Technical Changes

- Updated `main.qml`: Added dynamic dimension calculation based on `Screen.width` and `Screen.height`
- Updated `AddTimezoneDialog.qml`: Implemented responsive sizing with intelligent bounds
- Enhanced `install.sh`: Detects old version, asks confirmation, removes it automatically
- New `upgrade.sh`: One-command automatic upgrade with configuration backup
- All version strings updated to 1.1.0

### 🐛 Bug Fixes

- Fixed popup window cutoff issues on different screen resolutions
- Fixed dialog window sizing inconsistencies
- Fixed installation conflicts when upgrading from 1.0.0

### 📚 Documentation

- Added `UPGRADE_COMMANDS.md` with complete command-line upgrade instructions
- Added `UPDATE_SUMMARY_1.1.0.md` with detailed technical changes
- Added `SIZING_COMPARISON.txt` with visual before/after comparisons
- Added `QUICK_START_1.1.0.txt` with quick installation guide

### 🔄 Upgrade Path

**From 1.0.0 to 1.1.0:**

Easiest way:
```bash
unzip ZoneClock-1.1.0.zip
cd ZoneClock-1.1.0/plasmoid
chmod +x upgrade.sh
./upgrade.sh
systemctl --user restart plasma-plasmashell
```

Or use the new install.sh:
```bash
unzip ZoneClock-1.1.0.zip
cd ZoneClock-1.1.0/plasmoid
chmod +x install.sh
./install.sh
systemctl --user restart plasma-plasmashell
```

---

## Version 1.0.0 — Initial Release

Initial release of Zone Clock for KDE Plasma 6.

### Features
- Track multiple world timezones
- UTC Offset mode (fixed offsets)
- Country/City mode (IANA timezones with DST)
- Per-clock 12/24 hour format
- Show/hide seconds option
- Edit and delete entries
- Reorder timezones
- Network time sync for clock accuracy
- Automatic configuration saving
