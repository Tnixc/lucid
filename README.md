
  <img width="100" height="100" alt="Icon-1024" src="https://github.com/user-attachments/assets/05a6144e-92f0-4848-850e-a19777368a05" />

# Lucid

A macOS menu bar application designed to help reduce eye strain, maintain good posture, and encourage healthy work habits through customizable reminders and overlays.

## Features

### 🔔 Eye Strain Reminders

Periodic full-screen overlay reminders to give your eyes a rest using the 20-20-20 rule (look at something 20 feet away for 20 seconds every 20 minutes).

- **Customizable intervals**: Set reminder frequency in minutes
- **Personalized messaging**: Customize title and message text
- **Auto-dismiss**: Configurable auto-dismiss timer
- **Skip functionality**: Randomly positioned skip button to prevent muscle memory
- **Keyboard shortcuts**: Dismiss overlays with a customizable hotkey

<img width="600" alt="image" src="https://github.com/user-attachments/assets/a2d0891b-9598-4d55-b88b-fce57cf9d174" />


### ✨ Mini Overlay Reminders

Brief, non-intrusive animated reminders that appear at the bottom of your screen for quick wellness checks.

- **Animated pill design**: Smooth morphing animation from dot to pill and back
- **Customizable messages**: Set your own reminder text
- **SF Symbol icons**: Choose from a variety of wellness-themed icons
- **Adjustable timing**: Control both animation and display duration
- **Multi-screen support**: Appears on all connected displays simultaneously
- **Preset suggestions**: Quick access to common wellness reminders:
  - Posture check
  - Stay hydrated
  - Blink more
  - Stretch time
  - Deep breath
  - Look away

<img width="600" alt="image" src="https://github.com/user-attachments/assets/97620a27-a63e-4942-843b-bc162a04bfe7" />


### 🌙 Bedtime Reminders

Intelligent bedtime notifications to help maintain healthy sleep schedules.

- **Custom time range**: Set your preferred bedtime hours using visual timeline editor
- **Repeating reminders**: Optional periodic reminders throughout bedtime hours
- **Configurable intervals**: Control how often reminders repeat
- **Auto-dismiss option**: Choose whether overlays auto-dismiss or require manual action
- **Custom messaging**: Personalize title and message for bedtime notifications

<img width="600" alt="image" src="https://github.com/user-attachments/assets/70699ef4-88ef-4ec3-a536-82cb0c136f89" />


### ⚙️ General Settings

- **Launch at login**: Automatically start the app when you log in
- **Overlay opacity**: Choose from multiple material thickness options:
  - Ultra Thin
  - Thin
  - Medium
  - Thick
  - Ultra Thick
- **Click to dismiss**: Optional click-to-dismiss functionality for overlays
- **Keyboard shortcuts**: Customizable hotkey to dismiss any active overlay
- **Preview functionality**: Test overlays with current settings before committing

<img width="600" alt="image" src="https://github.com/user-attachments/assets/1e55f12e-2e30-44bf-955d-1fe8cb0bf035" />


### 📊 Menu Bar Integration

- **Live countdown**: Menu bar icon displays time until next reminder
- **Quick access**: Single click to open settings
- **Always available**: Discrete presence in your menu bar

<img width="326" height="343" alt="image" src="https://github.com/user-attachments/assets/f6a2960d-d0f1-4702-a20c-4eaa53bd18db" />


## Requirements

- macOS 14.6 or later
- Xcode 15.0+ (for building from source)

## Installation

### Option 1: Download Pre-built Binary

1. Download the latest release from the [Releases](../../releases) page
2. Move `EyeStrainApp.app` to your Applications folder
3. Launch the app
4. Grant necessary permissions when prompted

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/swift-macos-template.git
cd swift-macos-template

# Open in Xcode
open EyeStrainApp.xcodeproj

# Build and run (⌘R)
```

## Usage

1. **First Launch**: Grant permission for the app to display notifications and overlays
2. **Configure Settings**: Click the menu bar icon to access settings
3. **Customize Reminders**: Set up eye strain, mini overlay, and bedtime reminders to your preference
4. **Enable Launch at Login**: For consistent wellness reminders throughout your workday

### Keyboard Shortcuts

- **Dismiss Overlay**: Customizable (default: none) - Set in General settings

## Technology Stack

- **SwiftUI**: Modern declarative UI framework
- **AppKit**: Native macOS window and menu bar integration
- **Combine**: Reactive state management
- **UserDefaults**: Persistent settings storage

### Dependencies

- [SettingsAccess](https://github.com/orchetect/SettingsAccess) (v2.1.0+) - Settings window utilities
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) (v2.4.0+) - Keyboard shortcut management

## Project Structure

```
EyeStrainApp/
├── EyeStrainApp.swift          # App entry point
├── MainScene.swift             # Main scene configuration
├── Models/
│   └── AppState.swift          # Application state management
├── Settings/
│   ├── SettingsWindow.swift    # Settings window container
│   ├── GeneralSettingsTab.swift
│   ├── EyeStrainSettingsTab.swift
│   ├── MiniOverlaySettingsTab.swift
│   └── BedtimeSettingsTab.swift
├── Menu Bar/
│   ├── MenuBarModel.swift      # Menu bar state management
│   └── MenuBarView.swift       # Menu bar UI
├── Components/
│   ├── Overlay.swift           # Full-screen overlay component
│   ├── MiniOverlay.swift       # Mini animated overlay
│   ├── TimelineEditor.swift    # Visual time range editor
│   ├── Buttons.swift           # Reusable button components
│   ├── TextFields.swift        # Custom text field components
│   ├── UIDropdown.swift        # Dropdown component
│   ├── SettingItems.swift      # Settings UI components
│   └── InfoBox.swift           # Info box component
├── Services/
│   └── Notifier.swift          # Notification scheduling service
└── Utilities/
    └── Styles.swift            # Shared styling constants
```

## Configuration

All settings are stored in `UserDefaults` with the following keys:

### General Settings

- `launchAtLogin`: Boolean
- `overlayMaterial`: String (material type)
- `eyeStrainClickToDismiss`: Boolean

### Eye Strain Settings

- `eyeStrainInterval`: Integer (minutes)
- `eyeStrainTitle`: String
- `eyeStrainMessage`: String
- `eyeStrainDismissAfter`: Integer (seconds)

### Mini Overlay Settings

- `miniOverlayEnabled`: Boolean
- `miniOverlayText`: String
- `miniOverlayIcon`: String (SF Symbol name)
- `miniOverlayDuration`: Double (seconds)
- `miniOverlayHoldDuration`: Double (seconds)
- `miniOverlayInterval`: Integer (minutes)

### Bedtime Settings

- `bedtimeEnabled`: Boolean
- `bedtimeStartTime`: Date
- `bedtimeEndTime`: Date
- `bedtimeTitle`: String
- `bedtimeMessage`: String
- `bedtimeDismissAfter`: Integer (seconds)
- `bedtimeRepeatReminders`: Boolean
- `bedtimeRepeatInterval`: Integer (minutes)
- `bedtimeAutoDismiss`: Boolean

## Screenshots

### Settings Window

<img width="600" alt="image" src="https://github.com/user-attachments/assets/dedc3e06-b5ae-45e9-87f5-7604b41a020b" />


### Eye Strain Settings

<img width="600" alt="image" src="https://github.com/user-attachments/assets/92415ed9-32e9-45c2-b91b-1a6aa223ad54" />


### Mini Overlay Settings

<img width="600" alt="image" src="https://github.com/user-attachments/assets/4a5c4e1f-e701-4944-99d7-7799b57b2f07" />


## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Known Issues

- Skip button position randomization is intentional to prevent muscle memory development

## Future Enhancements

- [ ] Statistics tracking for reminder engagement
- [ ] Multiple reminder profiles
- [ ] Focus mode integration
- [ ] Pomodoro timer integration
- [ ] Export/import settings
- [ ] Dark mode specific customizations
- [ ] Sound notifications

## License

[Add your license here]

## Support

For questions, issues, or feedback:

- Email: enochlauenoch@gmail.com
- Issues: [GitHub Issues](../../issues)

## Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)
- Dependencies: SQLite.swift, SettingsAccess, KeyboardShortcuts
