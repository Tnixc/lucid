# Plan for Eye Strain and Bedtime Reminder App

## Overview
Build a macOS SwiftUI app that reminds users to take breaks for eye strain every 20 minutes and provides bedtime reminders. The app will be menu bar-based, with a countdown timer in the menu bar, a settings window for customization, and full-screen overlays for reminders.

## Key Features
1. **Menu Bar Integration**
   - Status item showing countdown to next eye strain break (e.g., "15m left").
   - Right-click menu for quick actions: Start/Pause timer, Open Settings, Quit.

2. **Eye Strain Reminders**
   - Every 20 minutes (customizable), display a full-screen, immovable overlay.
   - Overlay covers the entire screen with a blurred background.
   - Customizable text in the center (e.g., "Look away from the screen!").
   - Overlay auto-dismisses after 20 seconds or on user interaction (e.g., click to dismiss).
   - Window is always on top, borderless, and ignores mouse events except for dismissal.

3. **Bedtime Reminders**
   - At a set bedtime (e.g., 10 PM), show a similar overlay reminding to go to bed.
   - Customizable bedtime and reminder text.

4. **Settings Window**
   - Tabbed settings: General, Reminders.
   - General: Enable/disable features, launch on login.
   - Reminders: Customize eye strain interval, text, bedtime time, bedtime text.

5. **Persistence**
   - Use UserDefaults to save settings (intervals, texts, times).

## App Structure
- **Main App (`AppName.swift`)**: MenuBarExtra for menu bar, MainScene for settings window.
- **Menu Bar Model**: Manages countdown timer, updates status item.
- **Notifier Service**: Handles showing overlays for reminders.
- **Overlay Component**: Full-screen window with SwiftUI view.
- **Settings Window**: SwiftUI view with forms for customization.
- **Utilities**: Timer management, date/time helpers.

## Implementation Steps
1. Set up project based on Toki template.
2. Implement countdown timer in MenuBarModel.
3. Adapt Overlay component for customizable text and dismissal behavior.
4. Create Notifier service to trigger overlays at intervals and times.
5. Build Settings window with bindings to UserDefaults.
6. Add bedtime reminder logic.
7. Test full-screen overlay behavior (immovable, always on top).
8. Polish UI and add icons/assets     .

## Potential Challenges
- Ensuring overlay is truly immovable and covers the whole screen.
- Handling multiple displays (use NSScreen.main or iterate screens).
- Preventing dismissal until timer expires, but allow early dismissal.
- Integrating with system for launch on login.

## Timeline
- Day 1: Set up project, implement basic countdown and overlay.
- Day 2: Add settings, customize text and intervals.
- Day 3: Implement bedtime reminders, polish UI.
- Day 4: Testing, bug fixes, final touches.