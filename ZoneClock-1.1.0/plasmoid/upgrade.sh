#!/bin/bash

# Zone Clock Automatic Upgrade Script
# Upgrades from 1.0.0 to 1.1.0 with one command

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KDE_PREFIX="/usr"
PLASMOID_ID="zone-clock"
INSTALL_PATH="$KDE_PREFIX/share/kpackages/plasmoids/$PLASMOID_ID"

echo "========================================="
echo " Zone Clock - Automatic Upgrade Script"
echo " Upgrading 1.0.0 → 1.1.0"
echo "========================================="
echo ""

# Check if old version exists
if [ ! -d "$INSTALL_PATH" ]; then
    echo "❌ ERROR: Zone Clock is not installed!"
    echo ""
    echo "Run './install.sh' for a fresh installation instead."
    exit 1
fi

echo "✓ Found Zone Clock at: $INSTALL_PATH"
echo ""

# Get current version
CURRENT_VERSION=$(grep '"Version"' "$INSTALL_PATH/metadata.json" | grep -oP '"\K[^"]+' | tail -1)
echo "Current version: $CURRENT_VERSION"
echo "New version: 1.1.0"
echo ""

read -p "Proceed with upgrade? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Upgrade cancelled."
    exit 1
fi

echo ""
echo "Step 1: Backing up your configuration..."
BACKUP_DIR="$HOME/.config/zone-clock-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
if [ -f "$HOME/.config/plasmarc" ]; then
    cp "$HOME/.config/plasmarc" "$BACKUP_DIR/"
    echo "✓ Configuration backed up to: $BACKUP_DIR"
else
    echo "ℹ️  No configuration to backup"
fi
echo ""

echo "Step 2: Uninstalling old version..."
sudo rm -rf "$INSTALL_PATH"
echo "✓ Old version uninstalled"
echo ""

echo "Step 3: Building new version..."
BUILD_DIR="$SCRIPT_DIR/build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake -DCMAKE_INSTALL_PREFIX="$KDE_PREFIX" ..
make -j$(nproc)
echo "✓ Build complete"
echo ""

echo "Step 4: Installing new version..."
sudo make install
echo "✓ Version 1.1.0 installed"
echo ""

echo "========================================="
echo "✓ Upgrade complete!"
echo "========================================="
echo ""

echo "What happens next:"
echo "  ✓ Your timezone configurations are automatically preserved"
echo "  ✓ The popup will now properly resize on your screen"
echo "  ✓ All dialogs will fit better on any resolution"
echo ""

echo "Restart Plasma to see the changes:"
echo ""
echo "  systemctl --user restart plasma-plasmashell"
echo ""
echo "Or:"
echo ""
echo "  plasmashell --replace"
echo ""

if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
    echo "Backup saved at: $BACKUP_DIR"
fi
echo ""
echo "Done! 🌍"
