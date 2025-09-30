# Mini Overlay Module

A lightweight, non-intrusive overlay component for displaying brief text messages with smooth animations.

## Overview

The Mini Overlay is a new overlay type designed for displaying short, informative messages (like "Posture check", "Stay hydrated", etc.) without interrupting the user's workflow. It appears briefly at the bottom center of all screens with an elegant animation sequence.

## Features

- **Non-intrusive**: Appears at bottom center, doesn't block the main work area
- **Non-interactive**: Ignores mouse events, won't interfere with user actions
- **Multi-screen support**: Displays simultaneously on all connected screens
- **Auto-dismissing**: Automatically closes after animation completes
- **Customizable duration**: Adjust animation speed if needed
- **System integration**: Uses system accent color for visual consistency
- **Smooth animations**: Spring-based animations throughout the sequence

## Animation Sequence

The Mini Overlay follows a carefully choreographed animation:

1. **Fly In** (0.0s) - Small dot flies up from bottom of screen
2. **Large Circle** (0.4s) - Expands to large circle
3. **Pill Shape** (0.75s) - Morphs horizontally into pill with text fading in
4. **Hold** (2.2s) - Displays message for ~1.5 seconds
5. **Shrink to Circle** (2.5s) - Text fades out, morphs back to circle
6. **Shrink to Dot** (2.5s) - Morphs back to small dot
7. **Fly Away** (2.8s) - Flies back down off screen
8. **Dismiss** (3.15s) - Total animation completes

**Total Duration**: ~3.15 seconds (default, customizable)

## Usage

### Basic Usage

```swift
Notifier.shared.showMiniOverlay(text: "Posture check")
```

### With Custom Duration

```swift
// Faster animation (2 seconds total)
Notifier.shared.showMiniOverlay(text: "Quick reminder", duration: 2.0)

// Slower animation (5 seconds total)
Notifier.shared.showMiniOverlay(text: "Take your time", duration: 5.0)
```

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

### Typography
- **Font size**: 18pt
- **Font weight**: Semibold
- **Color**: White

## Testing

A test button is available in the menu bar dropdown:
1. Click the menu bar icon
2. Click "Test Mini Overlay"
3. A random wellness message will appear

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
- **Mouse events**: Disabled (completely non-interactive)
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

## Future Enhancements

Potential improvements:
- [ ] Custom colors per message
- [ ] Icon support alongside text (SF Symbols with interpolation)
- [ ] Sound effects option
- [ ] Multiple animation styles
- [ ] Position customization (top/bottom/sides)
- [ ] Persistent mini overlays (until dismissed)
- [ ] Queue system for multiple messages
- [ ] Do Not Disturb integration
- [ ] Variable blur effects during animation
- [ ] Haptic feedback integration

## License

Part of EyeStrainApp - See main project LICENSE file.