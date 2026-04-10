<p align="center">
  <img src="BoostTimer/Resources/Assets.xcassets/AppIcon.appiconset/icon_1024.png" width="128" height="128" alt="Boost Timer Icon">
</p>

<h1 align="center">⚡ Boost Timer</h1>

<p align="center">
  <strong>Minimal floating countdown timer for macOS</strong><br>
  Always-on-top • Semi-transparent • Multiple timers • Native SwiftUI
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9%2B-orange" alt="Swift">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
</p>

---

🇷🇺 [Документация на русском](README_RU.md)

## Features

- **Always on Top** — floating window stays above all other windows
- **Semi-transparent** — glassmorphism effect, blends with your desktop
- **Multiple Timers** — run several timers simultaneously in one compact window
- **Drag Anywhere** — position the timer anywhere on your screen
- **Presets** — quick presets: 1, 3, 5, 10, 15, 25, 30 minutes
- **Custom Time** — manual input with minutes and seconds steppers
- **Named Timers** — label each timer (e.g., "Meeting", "Break")
- **Warning Alerts** — configurable threshold (default: 3 min) with:
  - Soft chime sound
  - Orange pulsing glow
  - Removed transparency
- **Finish Alerts** — when timer reaches 00:00:
  - Alert sound
  - Red pulsing animation
  - macOS system notification
- **Dark / Light Theme** — toggle between themes, preference is saved
- **Sound Settings** — choose from 14 macOS system sounds, preview, or mute
- **Lightweight** — native SwiftUI, ~5MB, minimal resource usage

## Screenshots

<p align="center">
  <img src="screenshots/add_timer.png" width="300" alt="Add Timer">
</p>

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0+ (for building from source)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (installed automatically via `make`)

## Installation

### Option 1: Build from Source

```bash
# Clone the repository
git clone https://github.com/awens84/timer.git
cd timer

# Build and run (installs XcodeGen if needed)
make run
```

### Option 2: Build Release & Install

```bash
make build
make install  # Copies to /Applications
```

### Option 3: Open in Xcode

```bash
make generate  # Creates BoostTimer.xcodeproj
open BoostTimer.xcodeproj
# Then press ⌘R to run
```

## Usage

1. **Launch** — the timer appears as a floating panel in the top-right corner
2. **Add Timer** — click "Новый таймер" or press `⌘N`
3. **Set Time** — use presets or manual input, optionally name the timer
4. **Start** — press the play button ▶
5. **Drag** — grab anywhere on the panel to reposition
6. **Settings** — click the ⚙ gear icon to configure theme, sounds, and warning threshold

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘N` | New timer |
| `⌘W` | Close (quit) |

## Project Structure

```
BoostTimer/
├── App/
│   ├── BoostTimerApp.swift        # Entry point
│   └── AppDelegate.swift          # FloatingPanel (NSPanel) setup
├── Models/
│   └── TimerItem.swift            # Timer model + state machine
├── ViewModels/
│   └── TimerListViewModel.swift   # Timer collection management
├── Views/
│   ├── MainView.swift             # Root view with timer list
│   ├── TimerRowView.swift         # Single timer row + animations
│   ├── AddTimerSheet.swift        # New timer dialog
│   └── SettingsSheet.swift        # Settings dialog
├── Services/
│   ├── SoundService.swift         # System sound playback
│   └── NotificationService.swift  # macOS notifications
├── Utilities/
│   └── Theme.swift                # Color definitions
└── Resources/
    ├── Info.plist
    └── Assets.xcassets/
```

## Technical Details

- **Window**: `NSPanel` with `.nonactivatingPanel` — doesn't steal focus from other apps
- **Always on top**: `.floating` window level + `hidesOnDeactivate = false`
- **Transparency**: `.ultraThinMaterial` SwiftUI background
- **Timer precision**: `Timer` with 100ms tick on `.common` RunLoop mode (works during window drag)
- **Sounds**: macOS built-in system sounds via `NSSound` — no bundled audio files
- **Settings**: `@AppStorage` (UserDefaults) — persisted automatically
- **Architecture**: MVVM with `@Observable` (Observation framework)

## License

MIT — see [LICENSE](LICENSE)

## Author

Made by [@awens84](https://github.com/awens84)
