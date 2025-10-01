  <img width="100" height="100" alt="Icon-1024" src="https://github.com/user-attachments/assets/05a6144e-92f0-4848-850e-a19777368a05" />

# Lucid



https://github.com/user-attachments/assets/8241efe4-3ddc-460c-bddc-9a2155a73f04

###### please ignore the artifacting of the background, it's from the recording.


A macOS menu bar application designed to help reduce eye strain, maintain good posture, and encourage healthy work habits through customizable reminders and overlays.

## ✨ Key Features

- 🔔 **Eye Strain Reminders** - Full-screen overlays following the 20-20-20 rule
- ✨ **Mini Overlay Reminders** - Non-intrusive animated wellness reminders
- 🌙 **Bedtime Reminders** - Smart sleep schedule notifications
- 🎥 **Presentation Mode** - Auto-pause during screen sharing (NEW)
- 🔊 **Sound Effects** - Customizable audio notifications (NEW)
- 🎨 **Full Customization** - Colors, timing, sounds, and more

## Features

### 🔔 Eye Strain Reminders

Periodic full-screen overlay reminders to give your eyes a rest using the 20-20-20 rule (look at something 20 feet away for 20 seconds every 20 minutes).

- **Customizable intervals**: Set reminder frequency in minutes
- **Personalized messaging**: Customize title and message text
- **Auto-dismiss**: Configurable auto-dismiss timer
- **Skip functionality**: Randomly positioned skip button to prevent muscle memory
- **Keyboard shortcuts**: Dismiss overlays with a customizable hotkey

- **Enable toggle**: Turn eye strain reminders on/off
- **Preview button**: Test reminders with current settings

<img width="600" alt="image" src="https://github.com/user-attachments/assets/b808580b-c13d-4526-8bd3-9e3c340ea79a" />



### ✨ Mini Overlay Reminders

Brief, non-intrusive animated reminders that appear at the bottom of your screen for quick wellness checks.

- **Animated pill design**: Smooth morphing animation from dot to pill and back
- **Customizable messages**: Set your own reminder text
- **SF Symbol icons**: Choose from a variety of wellness-themed icons
- **Adjustable timing**: Control both animation and display duration
- **Multi-screen support**: Appears on all connected displays simultaneously
- **Custom colors**: Choose background and foreground colors
- **Vertical offset**: Adjust distance from bottom of screen
- **Enable toggle**: Turn mini overlays on/off
- **Preset suggestions**: Quick access to common wellness reminders:
  - Posture check
  - Stay hydrated
  - Blink more
  - Stretch time
  - Deep breath
  - Look away



https://github.com/user-attachments/assets/88542cdf-c534-40a6-8461-5bb878fd7adb



### 🌙 Bedtime Reminders

Intelligent bedtime notifications to help maintain healthy sleep schedules.

- **Custom time range**: Set your preferred bedtime hours using visual timeline editor
- **Repeating reminders**: Optional periodic reminders throughout bedtime hours
- **Configurable intervals**: Control how often reminders repeat
- **Auto-dismiss option**: Choose whether overlays auto-dismiss or require manual action
- **Custom messaging**: Personalize title and message for bedtime notifications
- **Persistent mode**: Continuously check and show overlay if past bedtime (NEW)

<img width="946" height="973" alt="image" src="https://github.com/user-attachments/assets/5d343528-6e9f-4578-b523-f71e6f3a6730" />


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
- **Global alerts toggle**: Master switch to enable/disable all reminders

<img width="948" height="799" alt="image" src="https://github.com/user-attachments/assets/bd5df216-b556-4eef-9af1-083891f1a049" />


### 🎥 Presentation Mode Detection (NEW)

Automatically pauses all reminders when you're presenting or screen sharing to avoid embarrassing interruptions.

- **Auto-detection**: Monitors for active screen sharing and presentation apps
- **Supported apps**: Zoom, Teams, Meet, Webex, Discord, Skype, and more
- **Presentation software**: Keynote, PowerPoint, Google Slides, Prezi
- **Fullscreen detection**: Recognizes when apps are in presentation mode
- **Zero configuration**: Works automatically in the background
- **Toggleable**: Can be disabled in General settings if needed

**Supported Applications:**

- Video conferencing: Zoom, Microsoft Teams, Google Meet, Webex, Skype, Discord, RingCentral, GoToMeeting, BlueJeans
- Presentation: Keynote, PowerPoint, Google Slides, Prezi, PDF Expert, Preview

### 🔊 Sound Effects (NEW)

Add audio feedback to your reminders for better awareness.

- **10 system sounds**: Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink, or None
- **Volume control**: Adjustable from 0% to 100%
- **Test button**: Preview sounds before selecting
- **Smart playback**: Only plays for scheduled reminders (not preview buttons)
- **Respects presentation mode**: No sounds during presentations or when settings are open

### 📊 Menu Bar Integration

- **Live countdown**: Menu bar icon displays time until next reminder
- **Quick access**: Single click to open settings
- **Always available**: Discrete presence in your menu bar

<img width="284" height="301" alt="image" src="https://github.com/user-attachments/assets/d47f0fef-6c9b-4404-97c3-49a13cdc3a13" />


## Requirements

- macOS 14.6 or later
- Xcode 15.0+ (for building from source)

## Installation

### Option 1: Download Pre-built Binary

1. Download the latest release from the releases page
2. Move `Lucid.app` to your Applications folder
3. Launch the app
4. Grant necessary permissions when prompted

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/swift-macos-template.git
cd swift-macos-template

# Open in Xcode
open Lucid.xcodeproj

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
Lucid/
├── Lucid.swift                 # App entry point
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
│   ├── Notifier.swift              # Notification scheduling service
│   ├── PresentationModeDetector.swift  # Screen sharing detection (NEW)
│   └── SoundManager.swift          # Sound effect management (NEW)
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

- `eyeStrainEnabled`: Boolean
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
- `miniOverlayBackgroundColor`: Data (NSColor archived)
- `miniOverlayForegroundColor`: Data (NSColor archived)
- `miniOverlayUseCustomColors`: Boolean
- `miniOverlayVerticalOffset`: Integer (pixels)

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
- `bedtimePersistent`: Boolean

### Sound & Presentation Settings (NEW)

- `soundEffectsEnabled`: Boolean
- `reminderSoundEffect`: String (sound name)
- `soundEffectsVolume`: Double (0.0-1.0)
- `disableDuringPresentation`: Boolean

## Screenshots

### Settings Window

<img width="600" alt="image" src="https://github.com/user-attachments/assets/dedc3e06-b5ae-45e9-87f5-7604b41a020b" />

### Eye Strain Settings

<img width="600" alt="image" src="https://github.com/user-attachments/assets/92415ed9-32e9-45c2-b91b-1a6aa223ad54" />

### Mini Overlay Settings

<img width="600" alt="image" src="https://github.com/user-attachments/assets/4a5c4e1f-e701-4944-99d7-7799b57b2f07" />

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Recent Updates

### Version "Working Hell yeah" (Latest)

- ✅ **Presentation Mode Detection** - Auto-pause during screen sharing
- ✅ **Sound Effects** - 10 customizable notification sounds
- ✅ **Enhanced Mini Overlays** - Custom colors and vertical offset
- ✅ **Eye Strain Toggle** - Enable/disable eye strain reminders
- ✅ **Persistent Bedtime Mode** - Continuous bedtime monitoring
- ✅ **Improved Animation** - Smoother mini overlay transitions
- ✅ **Smart Behavior** - Respects settings window and presentation state

## Known Issues

- Skip button position randomization is intentional to prevent muscle memory development
- Presentation detection requires apps to be active/frontmost
- Some web-based conferencing (in browsers) may not be detected

## Future Enhancements

- [ ] Statistics tracking for reminder engagement
- [ ] Multiple reminder profiles (work, home, weekend)
- [ ] Pomodoro timer integration
- [ ] Stretch routine reminders with guided exercises
- [ ] Calendar integration for smart scheduling
- [ ] Export/import settings
- [ ] Custom sound upload
- [ ] Activity detection improvements


## Support

For questions, issues, or feedback:

- Open an issue.
- Email: enochlauenoch@gmail.com

## Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)
- Dependencies: SettingsAccess, KeyboardShortcuts

