╔══════════════════════════════════════════════════════════════════════════╗
║                    ZONE CLOCK 1.1.0 - UPGRADE GUIDE                     ║
║              Auto-Replace Your 1.0.0 Installation                       ║
╚══════════════════════════════════════════════════════════════════════════╝

👋 WELCOME!

If you have Zone Clock 1.0.0 installed, upgrading to 1.1.0 is SUPER EASY.
This version automatically detects and replaces the old version.

═══════════════════════════════════════════════════════════════════════════

⚡ FASTEST WAY (One Command - Recommended!)

    cd plasmoid
    chmod +x upgrade.sh
    ./upgrade.sh

    That's it! Your old version is automatically replaced.
    Then just restart Plasma:
    
    systemctl --user restart plasma-plasmashell


═══════════════════════════════════════════════════════════════════════════

🚀 ALTERNATIVE (Interactive Installer)

    cd plasmoid
    chmod +x install.sh
    ./install.sh

    This will ask you if you want to replace the old version, then do it.


═══════════════════════════════════════════════════════════════════════════

🔍 WHAT CHANGES?

    ✓ Popup window now adapts to your screen resolution (no more cutoff!)
    ✓ Dialogs size properly on all displays
    ✓ Installation automatically replaces 1.0.0
    ✓ All your timezone settings are preserved
    ✓ No configuration needed

═══════════════════════════════════════════════════════════════════════════

📚 NEED MORE HELP?

    For detailed upgrade instructions, see:
    
    plasmoid/UPGRADE_COMMANDS.md     ← All upgrade methods with examples
    UPGRADE_GUIDE_COMPLETE.md         ← Master guide with troubleshooting
    SIZING_COMPARISON.txt              ← Visual before/after comparison
    QUICK_START_1.1.0.txt             ← Quick reference guide


═══════════════════════════════════════════════════════════════════════════

✅ AFTER UPGRADING

    1. Your timezone list is automatically preserved
    2. All settings (12/24 hour, show seconds, etc.) are kept
    3. The popup resizes properly on your screen
    4. Everything just works!


═══════════════════════════════════════════════════════════════════════════

🎯 SUMMARY

    1. cd plasmoid
    2. chmod +x upgrade.sh
    3. ./upgrade.sh
    4. systemctl --user restart plasma-plasmashell
    5. Done! ✨


═══════════════════════════════════════════════════════════════════════════

Questions? Check the documentation files:
    - README.md                 Full usage guide
    - CHANGELOG.md              What changed in 1.1.0
    - BUILD_NOTES.md            Technical details
    - UPGRADE_COMMANDS.md       All upgrade methods

═══════════════════════════════════════════════════════════════════════════

Ready? Let's upgrade! 🌍

    cd plasmoid && chmod +x upgrade.sh && ./upgrade.sh
