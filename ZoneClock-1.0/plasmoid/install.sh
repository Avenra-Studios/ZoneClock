#!/bin/bash

# Zone Clock Plasmoid Installation Script for Fedora KDE Plasma 6

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build"

echo "========================================="
echo " Zone Clock - KDE Plasma 6 Installer"
echo "========================================="
echo ""

# Fedora check
if [ ! -f /etc/fedora-release ]; then
    echo "⚠️  This script is optimized for Fedora KDE."
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


KDE_PREFIX="/usr"

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


echo "Installing..."

sudo make install


echo ""
echo "========================================="
echo "✓ Zone Clock installed successfully!"
echo "========================================="
echo ""


echo "Restart Plasma:"
echo ""

echo "  systemctl --user restart plasma-plasmashell"

echo ""

echo "Or manually:"
echo "  plasmashell --replace"

echo ""

echo "Add widget:"
echo "  Right click panel"
echo "  → Add Widgets"
echo "  → Search: Zone Clock"

echo ""

echo "Test without installing:"
echo "  plasmoidviewer -a $SCRIPT_DIR"

echo ""

echo "Done!"