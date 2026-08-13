#!/bin/bash

# Zone Clock Plasmoid Installation Script for Fedora KDE Plasma 6
# Version 1.1.0 - Now with automatic old version detection and removal

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build"
KDE_PREFIX="/usr"
PLASMOID_ID="zone-clock"
INSTALL_PATH="$KDE_PREFIX/share/kpackages/plasmoids/$PLASMOID_ID"

echo "========================================="
echo " Zone Clock - KDE Plasma 6 Installer"
echo " Version 1.1.0"
echo "========================================="
echo ""

# Fedora check
if [ ! -f /etc/fedora-release ]; then
    echo "⚠️  This script is optimized for Fedora KDE."
    echo ""
fi

# Check if old version is installed
echo "Checking for old Zone Clock installation..."
if [ -d "$INSTALL_PATH" ]; then
    echo "✓ Found existing Zone Clock installation at: $INSTALL_PATH"
    echo ""
    echo "The installer will uninstall the old version and install 1.1.0"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Uninstalling old version..."
        sudo rm -rf "$INSTALL_PATH"
        echo "✓ Old version removed"
        echo ""
    else
        echo "Installation cancelled."
        exit 1
    fi
else
    echo "✓ No old version found (fresh install)"
    echo ""
fi

echo "Checking dependencies..."

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


echo "✓ Dependencies installed"
echo ""

echo "Using KDE prefix: $KDE_PREFIX"
echo ""

echo "Cleaning old build..."
rm -rf "$BUILD_DIR"

mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

echo "Configuring CMake..."

cmake \
    -DCMAKE_INSTALL_PREFIX="$KDE_PREFIX" \
    ..

echo "Building..."

make -j$(nproc)

echo "Installing Zone Clock 1.1.0..."

sudo make install

echo ""
echo "========================================="
echo "✓ Zone Clock 1.1.0 installed successfully!"
echo "========================================="
echo ""
echo "Installed at: $INSTALL_PATH"
echo ""

echo "NEXT STEPS:"
echo "==========="
echo ""
echo "1. Restart Plasma Shell (choose one):"
echo ""
echo "   Option A (recommended):"
echo "   $ systemctl --user restart plasma-plasmashell"
echo ""
echo "   Option B (alternative):"
echo "   $ plasmashell --replace"
echo ""

echo "2. Add the widget to your panel:"
echo "   • Right-click your panel"
echo "   • Select 'Add Widgets'"
echo "   • Search for 'Zone Clock'"
echo "   • Click it to add"
echo ""

echo "3. Test without installing (during development):"
echo "   $ plasmoidviewer -a $SCRIPT_DIR"
echo ""

echo "Done! 🌍"