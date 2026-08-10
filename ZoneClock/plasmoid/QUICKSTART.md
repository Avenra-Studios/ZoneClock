# Zone Clock - Quick Start Guide

## What You Just Created

A **KDE Plasma Plasmoid** (system tray widget) that manages multiple world timezones.

### Features
✅ **World icon** in system tray  
✅ **Popup menu** shows all saved timezones  
✅ **Real-time clock** - updates every second  
✅ **Add/Edit/Delete** timezones with custom names  
✅ **Reorder** by dragging (when 2+ timezones)  
✅ **Time format** - choose 12 or 24-hour per timezone  
✅ **Persistent** - saves to KDE config automatically  

---

## Installation (Fedora KDE)

### 1. Install Dependencies
```bash
sudo dnf install -y \
  cmake extra-cmake-modules \
  plasma-framework-devel \
  kf6-ki18n-devel kf6-plasma-devel \
  qt6-qtbase-devel qt6-qtdeclarative-devel
```

### 2. Build & Install
```bash
cd /home/martin/IdeaProjects/ZoneClock/plasmoid
bash install.sh
```

Or manually:
```bash
cd /home/martin/IdeaProjects/ZoneClock/plasmoid
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$(kf6-config --prefix) ..
make -j$(nproc)
sudo make install
```

### 3. Activate in Plasma
```bash
# Restart Plasma Shell
killall plasmashell
# It auto-restarts in ~2 seconds
```

### 4. Add to Panel
- Right-click panel → **Edit Mode**
- Click **Add Widgets**
- Search **"Zone Clock"** → Click to add

---

## Quick Test (Without Installation)

To test without installing system-wide:
```bash
cd /home/martin/IdeaProjects/ZoneClock/plasmoid
plasmoidviewer -a . zone-clock
```

This opens a test window with the widget loaded.

---

## Project Structure

```
plasmoid/
├── CMakeLists.txt          ← Build configuration
├── metadata.desktop        ← Plasmoid metadata
├── README.md               ← Detailed documentation
├── install.sh              ← Quick installer script
└── ui/
    ├── main.qml            ← Main UI (tray icon + popup)
    ├── TimezoneDelegateItem.qml   ← Each timezone entry
    ├── AddTimezoneDialog.qml      ← Add/Edit dialog
    ├── TimezoneModel.qml          ← Timezone list
    └── config.qml          ← Settings (minimal)
```

---

## How It Works

### UI Flow

1. **Click world icon** → Popup appears
2. **Click "+ Add Timezone"** → Dialog opens
3. **Enter name** (e.g., "Tokyo Office")
4. **Pick timezone** from dropdown
5. **Select time format** (12/24 hour)
6. **Click OK** → Saved! Shows in popup

### Reordering

- When 2+ zones exist, a **≡ drag button** appears
- Click it for "Move Up" / "Move Down" menu
- Changes saved immediately

### Editing

- Click **✏️ Edit button** on any entry
- Change name/timezone/format
- Click OK to save

### Deleting

- Click **🗑️ Delete button** on any entry
- Removed immediately

---

## Storage

User data stored in: `~/.config/plasmarc`  
(Automatic - no manual config needed)

---

## Troubleshooting

### Widget not showing after install?
```bash
# Clear cache
rm -rf ~/.cache/plasmoid*
# Restart
killall plasmashell
```

### Times show "Invalid TZ"?
- Check timezone spelling in dropdown
- Use IANA format: `America/New_York`, `Asia/Tokyo`, etc.

### Can't find timezone?
- ComboBox is searchable - type to filter
- E.g., type "new" to find "America/New_York"

### Need more timezones?
Edit `/home/martin/IdeaProjects/ZoneClock/plasmoid/ui/TimezoneModel.qml`  
Add entries to the `timezones` array in `Component.onCompleted`

---

## Development

**Modify UI?** Edit files in `ui/` directory  
**Rebuild:** `cd build && cmake .. && make -j$(nproc) && sudo make install`  
**Test:** `plasmoidviewer -a . zone-clock`

---

## Next Steps

1. Run `bash install.sh`
2. Restart Plasma (`killall plasmashell`)
3. Add widget to panel
4. Click world icon & add your first timezone!

Enjoy! 🌍⏰
