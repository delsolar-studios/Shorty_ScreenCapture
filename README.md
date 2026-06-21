# Shorty

For those with no time to spare — save 24 hours a year with one key.

Remaps your Mac's **F3** and **F4** keys (pressed *without* `fn`) from their default actions (Mission Control / Launchpad) into instant screenshot shortcuts.

- **F3** → select a region, copies straight to your clipboard
- **F4** → opens the screenshot toolbar (⌘⇧5)

No menu bar app, no background process to manage, nothing to open ever again. Works automatically after every restart.

## Usage

```
bash "Shorty V_002.sh"
```

Run it once. That's it. Safe to run again anytime — it won't create duplicates or break anything if it's already set up.

## What it actually does

This only uses tools already built into macOS — no third-party apps, no Homebrew, no permissions to approve in System Settings:

1. **`hidutil`** — remaps the raw keyboard signal F3/F4 send (at the driver level, before macOS decides it means "Mission Control" or "Launchpad") into two unused function keys, F13 and F14.
2. **A LaunchAgent** (`~/Library/LaunchAgents/com.user.f3-screenshot.plist`) — reapplies that remap automatically every time you log in, so it survives restarts.
3. **`defaults write`** — tells macOS that F13 should trigger its existing "selection screenshot to clipboard" shortcut. F14 needs no change — macOS already binds it to the screenshot toolbar by default.

Nothing is sent anywhere, no data is collected, and no files outside the two listed above are touched.

## Requirements

- macOS
- That's it.

## Undo

```
launchctl unload ~/Library/LaunchAgents/com.user.f3-screenshot.plist
rm ~/Library/LaunchAgents/com.user.f3-screenshot.plist
hidutil property --set '{"UserKeyMapping":[]}'
```

Then reset the screenshot shortcut back to default in System Settings → Keyboard → Keyboard Shortcuts → Screenshots.

— Santiago DS
