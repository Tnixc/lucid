# Mini Overlay Module

A lightweight, non-intrusive overlay component for displaying brief text messages with smooth animations and customizable icons.

## Overview

The Mini Overlay is a new overlay type designed for displaying short, informative messages (like "Posture check", "Stay hydrated", etc.) without interrupting the user's workflow. It appears briefly at the bottom center of all screens with an elegant animation sequence.

Configure the mini overlay through the **Settings → Mini Overlay** tab to enable automatic reminders at customizable intervals.

## Features

- **Non-intrusive**: Appears at bottom center, doesn't block the main work area
- **Click to dismiss**: Click anywhere on the overlay to dismiss it instantly
- **Multi-screen support**: Displays simultaneously on all connected screens
- **Auto-dismissing**: Automatically closes after animation completes
- **Customizable**: Adjust text, icon, duration, and frequency through settings
- **Scheduled reminders**: Automatic reminders at configurable intervals
- **Icon support**: Choose from 15+ SF Symbols to accompany your message
- **Preset messages**: Quick-select common wellness reminders
- **System integration**: Uses system accent color for visual consistency
- **Smooth animations**: Interpolated shape morphing throughout the sequence

## Animation Sequence

The Mini Overlay follows a carefully choreographed animation:

1. **Fly In** (0.0s) - Small dot flies up from bottom of screen
2. **Large Circle** (0.4s) - Expands to large circle
3. **Pill Shape** (0.75s) - Morphs horizontally into pill with text fading in
4. **Hold** (configurable) - Displays message for 1.5-30 seconds (default: 1.5s)
5. **Shrink to Circle** - Text fades out, morphs back to circle
6. **Shrink to Dot** - Morphs back to small dot
7. **Fly Away** - Flies back down off screen
8. **Dismiss** - Animation completes

**Total Duration**: Configurable based on animation and hold duration settings

**Note**: Click anywhere on the overlay to dismiss it immediately at any time.

## Settings Configuration

### Accessing Settings

1. Click the app's menu bar icon
2. Click the gear icon to open Settings
3. Navigate to the **Mini Overlay** tab

### Available Settings

#### Enable Mini Overlays
Toggle to enable/disable automatic mini overlay reminders.

#### Reminder Text
Customize the message displayed in the overlay (e.g., "Posture check", "Stay hydrated").

#### Icon
Choose from 15+ SF Symbols to display alongside your text:
- sparkles
- star.fill
- heart.fill
- leaf.fill
- drop.fill
- figure.stand
- figure.walk
- eye.fill
- lungs.fill
- brain.head.profile
- cup.and.saucer.fill
- bell.fill
- lightbulb.fill
- sun.max.fill
- moon.fill

#### Animation Duration
Adjust how long the entire animation takes (2.0 - 6.0 seconds).

#### Display Duration
Control how long the message stays visible in full (1.0 - 30.0 seconds). This is the hold time when the pill is fully expanded with text showing.

#### Frequency
Set the interval between reminders in minutes (default: 30 minutes).

#### Preset Messages
Quick-select buttons for common wellness reminders:
- Posture check (figure.stand)
- Stay hydrated (drop.fill)
- Blink more (eye.fill)
- Stretch time (figure.walk)
- Deep breath (lungs.fill)
- Look away (sparkles)

## Programmatic Usage

### Basic Usage

```swift
// Simple text only
Notifier.shared.showMiniOverlay(text: "Posture check")

// With icon
Notifier.shared.showMiniOverlay(text: "Stay hydrated", icon: "drop.fill")

// With custom duration
Notifier.shared.showMiniOverlay(text: "Quick reminder", icon: "sparkles", duration: 2.0)

// With custom hold duration (how long message stays visible)
Notifier.shared.showMiniOverlay(text: "Read this carefully", icon: "book.fill", duration: 3.15, holdDuration: 5.0)
```

### Advanced Usage

```swift
// Full customization
let text = "Take a break"
let icon = "figure.walk"
let duration = 4.0
let holdDuration = 3.0  // Message visible for 3 seconds
Notifier.shared.showMiniOverlay(text: text, icon: icon, duration: duration, holdDuration: holdDuration)
```</parameter>

<old_text line=78>
**Parameters:**
- `text: String` - The message to display
- `screen: NSScreen` - The screen to display on
- `duration: TimeInterval` - Total animation duration (default: 3.15)
- `onDismiss: @escaping () -> Void` - Callback when animation completes

#### `Notifier.showMiniOverlay()`
Public API for triggering the mini overlay.

**Parameters:**
- `text: String` - The message to display
- `duration: TimeInterval` - Optional animation duration (default: 3.15)

## Example Messages

Perfect for brief reminders and wellness prompts:

- "Posture check"
- "Stay hydrated"
- "Blink more"
- "Stretch time"
- "Deep breath"
- "Look away"
- "Stand up"
- "Take a break"

## Implementation Details

### Files

- `EyeStrainApp/Components/MiniOverlay.swift` - Main component implementation
- `EyeStrainApp/Services/Notifier.swift` - Service integration

### Key Functions

#### `generateMiniOverlay()`
Creates the NSWindow for the mini overlay.

**Parameters:**
- `text: String` - The message to display
- `screen: NSScreen` - The screen to display on
- `duration: TimeInterval` - Total animation duration (default: 3.15)
- `onDismiss: @escaping () -> Void` - Callback when animation completes

#### `Notifier.showMiniOverlay()`
Public API for triggering the mini overlay.

**Parameters:**
- `text: String` - The message to display
- `duration: TimeInterval` - Optional animation duration (default: 3.15)

### Animation Parameters

All timing values scale proportionally with the `duration` parameter:

- **Spring animations**: Natural, bouncy feel for expansion/contraction
- **Content transitions**: `.interpolate` for smooth shape morphing
- **Damping**: Varies between 0.65-0.8 for different phases
- **Response times**: Tuned for smooth, fluid motion
- **Text transitions**: Fade in/out with easing for readability
- **Easing**: Ease-in for the final fly-away effect

## Visual Design

### Colors
- **Background**: System accent color
- **Text**: White (high contrast)
- **Shadow**: Subtle black shadow (opacity 0.25) with accent color glow

### Dimensions
- **Dot size**: 8pt diameter
- **Circle size**: 60pt diameter
- **Pill height**: 60pt
- **Pill padding**: 24pt horizontal
- **Icon size**: 18pt (when enabled)
- **Icon spacing**: 8pt from text

### Typography
- **Font size**: 18pt
- **Font weight**: Semibold
- **Color**: White

## Testing

Use the preview button in settings:
1. Open Settings → Mini Overlay tab
2. Configure your desired text and icon
3. Click the "Preview" button
4. The mini overlay will appear with your current settings

## Integration Ideas

The Mini Overlay is perfect for:

1. **Periodic reminders**
   - Posture checks every 30 minutes
   - Hydration reminders every hour
   - Blinking reminders for eye health

2. **Wellness prompts**
   - Breathing exercises
   - Stretch breaks
   - Quick movement reminders

3. **System notifications**
   - Timer completions
   - Milestone achievements
   - Gentle alerts

4. **Habit tracking**
   - Scheduled wellness habits
   - Custom user reminders
   - Health check-ins

## Technical Notes

### Window Properties
- **Level**: `.floating` (appears above most windows)
- **Mouse events**: Enabled (clickable to dismiss)
- **Collection behavior**: Joins all spaces, auxiliary to fullscreen
- **Background**: Transparent

### Performance
- Minimal resource usage
- No continuous animations (discrete phases)
- Auto-cleanup after dismissal
- No memory leaks (weak self references)

## Customization

To customize the appearance, edit these properties in `MiniOverlayView`:

```swift
private let dotSize: CGFloat = 8           // Initial dot size
private let circleSize: CGFloat = 60       // Circle diameter
private let pillHeight: CGFloat = 60       // Pill height
private let pillPadding: CGFloat = 24      // Horizontal padding
```

To adjust timing, modify the delay values in `startAnimation()`.

## Technical Implementation

### Shape Interpolation

**Key Innovation**: Single Capsule shape with animated dimensions instead of switching between different views.

**Before** (Phase-based approach):
```swift
// Multiple conditional views switching between states
if animationPhase == .pill {
    Capsule() // Pill view
} else {
    Circle() // Circle view
}
```

**After** (Interpolated approach):
```swift
// Single Capsule with animated width/height
Capsule()
    .frame(width: shapeWidth, height: shapeHeight)
    .contentTransition(.interpolate)
```

**Benefits**:
- Capsule naturally morphs between circle (width == height) and pill (width > height)
- SwiftUI interpolates the shape's path during transitions
- Eliminates view switching overhead
- Smoother, more organic animations
- Consistent identity throughout animation lifecycle

### Shape Interpolation Details

The overlay uses SwiftUI's `.contentTransition(.interpolate)` modifier to create smooth morphing animations between shapes. This provides:

- **Seamless transitions**: Circle to pill morphing happens through interpolation
- **No jarring jumps**: Continuous path animation between all states
- **GPU-accelerated**: SwiftUI optimizes interpolated content transitions
- **Fluid motion**: Natural, organic feel with spring physics
- **Performance**: Single view identity means less memory thrashing

### Animation State Management

Instead of an enum with discrete phases, the new approach uses:
- `@State var shapeWidth: CGFloat` - Animatable dimension
- `@State var shapeHeight: CGFloat` - Animatable dimension  
- `@State var textOpacity: Double` - Text fade timing
- `@State var overallOpacity: Double` - Entry/exit fading

This allows SwiftUI to interpolate between any two states smoothly

## Automation

The mini overlay system integrates with the app's timer to show reminders automatically:
- Checks occur every second alongside other app timers
- First reminder shows immediately when enabled
- Subsequent reminders follow the configured interval
- Reminders respect the app's active state
- No overlapping overlays (new ones replace existing)

### UserDefaults Keys

The following keys are used for persistence:
- `miniOverlayEnabled` (Bool) - Master toggle
- `miniOverlayText` (String) - Reminder message
- `miniOverlayIcon` (String) - SF Symbol name
- `miniOverlayDuration` (Double) - Total animation duration in seconds
- `miniOverlayHoldDuration` (Double) - How long message stays visible in seconds
- `miniOverlayInterval` (Int) - Minutes between reminders

## Future Enhancements

Potential improvements:
- [ ] Custom colors per message
- [ ] Multiple reminder profiles
- [ ] Sound effects option
- [ ] Multiple animation styles
- [ ] Position customization (top/bottom/sides)
- [ ] Persistent mini overlays (until dismissed)
- [ ] Queue system for multiple messages
- [ ] Do Not Disturb integration
- [ ] Variable blur effects during animation
- [ ] Haptic feedback integration
- [ ] Context-aware reminders (based on app usage)
- [ ] Custom icon uploads

## License

Part of EyeStrainApp - See main project LICENSE file.