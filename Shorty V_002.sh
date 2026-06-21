#!/bin/bash
# Shorty V_002
# For those with no time to spare — save 24 hours a year with one key.
# — Santiago DS
#
# Run once: bash "Shorty V_002.sh"
# Press F3 afterwards to select a region and copy it to your clipboard.
# Press F4 afterwards to open the screenshot toolbar.
#
# Safe to re-run: this replaces (not duplicates) any mapping from a
# previous run of this script, including older versions.

MC_SRC=0xff0100000010    # Mission Control key (F3 without fn)
F3_DST=0x000700000068    # F13

LP_SRC_A=0xff0100000004  # Launchpad key (F4 without fn), vendor-page variant
LP_SRC_B=0x000c00000221  # Launchpad key (F4 without fn), consumer-page variant
F4_DST=0x000700000069    # F14

MAPPING="{\"UserKeyMapping\":[
  {\"HIDKeyboardModifierMappingSrc\":$MC_SRC,\"HIDKeyboardModifierMappingDst\":$F3_DST},
  {\"HIDKeyboardModifierMappingSrc\":$LP_SRC_A,\"HIDKeyboardModifierMappingDst\":$F4_DST},
  {\"HIDKeyboardModifierMappingSrc\":$LP_SRC_B,\"HIDKeyboardModifierMappingDst\":$F4_DST}
]}"

echo "→ Remapping F3 → F13 and F4 → F14 via hidutil..."
if ! hidutil property --set "$MAPPING" >/dev/null; then
  echo ""
  echo "✗ hidutil couldn't remap the keys — this is almost always a permission issue."
  echo "  Go to System Settings → Privacy & Security → Input Monitoring,"
  echo "  and turn ON access for Terminal (or whichever app you ran this script from)."
  echo "  Then run this script again."
  exit 1
fi

CHECK=$(hidutil property --get UserKeyMapping)
if [[ "$CHECK" != *"$((F3_DST))"* ]] || [[ "$CHECK" != *"$((F4_DST))"* ]]; then
  echo "✗ Remap didn't take effect (hidutil reported success but the mapping isn't active). Try again after a fresh login."
  exit 1
fi
echo "  ✓ remap active"

echo "→ Making the remap persist across reboots..."
PLIST=~/Library/LaunchAgents/com.user.f3-screenshot.plist
mkdir -p ~/Library/LaunchAgents
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.f3-screenshot</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>$MAPPING</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

launchctl unload "$PLIST" >/dev/null 2>&1
if ! launchctl load "$PLIST"; then
  echo "✗ Couldn't load the LaunchAgent — the remap will NOT survive a restart."
  echo "  Try running this script again, or check ~/Library/LaunchAgents permissions."
  exit 1
fi
if ! launchctl list | grep -q com.user.f3-screenshot; then
  echo "✗ LaunchAgent didn't register — the remap will NOT survive a restart."
  exit 1
fi
echo "  ✓ will reapply automatically at every login"

echo "→ Assigning F13 as selection screenshot to clipboard..."
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 31 \
  '<dict><key>enabled</key><integer>1</integer><key>value</key><dict><key>parameters</key><array><integer>65535</integer><integer>105</integer><integer>0</integer></array><key>type</key><string>standard</string></dict></dict>'
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

if defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys 2>/dev/null | grep -A2 '31 =' | grep -q 'enabled = 1'; then
  echo "  ✓ F3 shortcut assigned"
else
  echo "✗ Couldn't confirm the F3 shortcut was assigned. Open System Settings → Keyboard → Keyboard Shortcuts → Screenshots and check it manually."
fi

echo "→ F14 is checked: macOS already binds it to the screenshot toolbar (⌘⇧5) by default."
echo "  Nothing else to install."

echo ""
echo "Done!"
echo "  F3 → select a region, copies to your clipboard instantly."
echo "  F4 → opens the screenshot toolbar (⌘⇧5)."
echo "Both work automatically after every restart."
