# Zone Clock 1.1.0 - Upgrade Commands

Complete step-by-step command-line instructions to upgrade from 1.0.0 to 1.1.0.

---

## 🚀 FASTEST WAY (Automatic Upgrade)

If you have **Zone Clock 1.0 already installed**, use this:

```bash
# 1. Extract the new version
unzip ZoneClock-1.1.0.zip
cd ZoneClock-1.1.0/plasmoid

# 2. Make scripts executable
chmod +x install.sh upgrade.sh

# 3. Run the automatic upgrade (easiest!)
./upgrade.sh

# 4. Restart Plasma
systemctl --user restart plasma-plasmashell
```

**That's it!** Your old version will be automatically replaced. Your timezone configurations are preserved.

---

## 📋 MANUAL UPGRADE (Step-by-Step)

### Step 1: Extract the new version

```bash
unzip ZoneClock-1.1.0.zip
cd ZoneClock-1.1.0/plasmoid
```

### Step 2: Uninstall the old version (1.0.0)

```bash
# Completely uninstall old version
sudo rm -rf /usr/share/kpackages/plasmoids/zone-clock

# Verify it's gone
ls /usr/share/kpackages/plasmoids/zone-clock
# Should say: No such file or directory
```

### Step 3: Install dependencies

```bash
sudo dnf install -y \
    cmake \
    make \
    gcc \
    gcc-c++ \
    pkg-config \
    extra-cmake-modules \
    kf6-ki18n-devel \
    kf6-kpackage-devel \
    kf6-kcoreaddons-devel \
    qt6-qtbase-devel \
    qt6-qtdeclarative-devel \
    qt6-qtsvg-devel
```

### Step 4: Build the new version

```bash
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make -j$(nproc)
```

### Step 5: Install version 1.1.0

```bash
sudo make install
```

### Step 6: Restart Plasma

```bash
systemctl --user restart plasma-plasmashell
```

---

## ⚙️ USING THE AUTOMATED INSTALLER

Even easier - just run the new `install.sh` script which now:
- ✅ Automatically detects old version
- ✅ Asks for confirmation
- ✅ Removes old version
- ✅ Installs 1.1.0
- ✅ Shows you what to do next

### Quick install:

```bash
unzip ZoneClock-1.1.0.zip
cd ZoneClock-1.1.0/plasmoid
chmod +x install.sh
./install.sh
```

---

## 🔄 COMPLETE UPGRADE FLOW

Here's the full process from download to working:

```bash
# 1. Download/extract
unzip ZoneClock-1.1.0.zip
cd ZoneClock-1.1.0/plasmoid

# 2. Option A: Automatic upgrade (if you have 1.0.0 installed)
chmod +x upgrade.sh
./upgrade.sh
# Done! Just restart Plasma.

# OR Option B: Clean install/replace via install.sh
chmod +x install.sh
./install.sh
# Done! Just restart Plasma.

# 3. Restart Plasma (required step)
systemctl --user restart plasma-plasmashell

# 4. Add to your panel
# Right-click panel → Add Widgets → Search "Zone Clock" → Click it
```

---

## 🎯 WHAT EACH COMMAND DOES

| Command | Purpose |
|---------|---------|
| `unzip ZoneClock-1.1.0.zip` | Extract the project |
| `chmod +x *.sh` | Make scripts executable |
| `./upgrade.sh` | Auto-upgrade from 1.0.0 → 1.1.0 |
| `./install.sh` | Interactive install (auto-detects old version) |
| `cmake -DCMAKE_INSTALL_PREFIX=/usr ..` | Configure build for system-wide install |
| `make -j$(nproc)` | Compile (uses all CPU cores) |
| `sudo make install` | Install to `/usr/share/kpackages/plasmoids/zone-clock` |
| `systemctl --user restart plasma-plasmashell` | Restart Plasma to load new version |
| `plasmoidviewer -a .` | Test without installing (development) |

---

## 🔍 VERIFY INSTALLATION

After installing, verify version 1.1.0 is active:

```bash
# Check installed version
cat /usr/share/kpackages/plasmoids/zone-clock/metadata.json | grep Version

# Should output:
# "Version": "1.1.0",

# Check files exist
ls -la /usr/share/kpackages/plasmoids/zone-clock/contents/ui/main.qml
ls -la /usr/share/kpackages/plasmoids/zone-clock/contents/ui/AddTimezoneDialog.qml
```

---

## ✅ CONFIGURATION PRESERVATION

Your timezone data is **automatically preserved** through Plasma's config system:

```bash
# Your settings are stored here (not deleted during upgrade):
cat ~/.config/plasmarc | grep -A 20 zone-clock

# Backup your config before upgrading (optional):
cp ~/.config/plasmarc ~/.config/plasmarc.backup-1.0.0
```

---

## 🆘 TROUBLESHOOTING

### "Command not found: cmake"
```bash
# Install build tools
sudo dnf install -y cmake extra-cmake-modules
```

### "Permission denied" when running script
```bash
# Make script executable
chmod +x install.sh
chmod +x upgrade.sh

# Then run it
./install.sh
```

### Plasma doesn't recognize the new version
```bash
# Kill and restart Plasma Shell
systemctl --user restart plasma-plasmashell

# Or manually:
plasmashell --replace

# Wait 5 seconds for it to restart
```

### Widget doesn't appear after installation
```bash
# Fully restart Plasma
systemctl --user restart plasma-plasmashell

# Then try adding it again:
# Right-click panel → Add Widgets → Search "Zone Clock"
```

### Want to uninstall completely
```bash
# Remove the plasmoid
sudo rm -rf /usr/share/kpackages/plasmoids/zone-clock

# Verify it's gone
ls /usr/share/kpackages/plasmoids/zone-clock
# Should say "No such file or directory"

# Restart Plasma
systemctl --user restart plasma-plasmashell
```

---

## 📊 SIDE-BY-SIDE COMPARISON

### Old Way (1.0.0)
```bash
# Had to manually find and delete old version
# Then install new version
# Hope nothing broke
```

### New Way (1.1.0)
```bash
# Just run this:
./upgrade.sh
# Done! Everything handled automatically
```

---

## 🎓 SCRIPT EXPLANATIONS

### upgrade.sh (Recommended for existing users)
```bash
# What it does:
1. ✅ Checks if 1.0.0 is installed
2. ✅ Backs up your config
3. ✅ Removes 1.0.0
4. ✅ Builds 1.1.0
5. ✅ Installs 1.1.0
6. ✅ Shows next steps

# Run it:
./upgrade.sh
```

### install.sh (Recommended for fresh installs or replacements)
```bash
# What it does:
1. ✅ Checks for old version (if found, asks to remove)
2. ✅ Installs all dependencies
3. ✅ Builds 1.1.0
4. ✅ Installs 1.1.0
5. ✅ Shows next steps

# Run it:
./install.sh
```

---

## 🌍 SUMMARY

**Upgrading is now super easy:**

```bash
# Extract → Make executable → Run script → Restart → Done!

unzip ZoneClock-1.1.0.zip && \
cd ZoneClock-1.1.0/plasmoid && \
chmod +x upgrade.sh && \
./upgrade.sh && \
systemctl --user restart plasma-plasmashell
```

**That's it! You're done.** ✨

All your settings are preserved, the new responsive sizing is active, and you're running 1.1.0.
