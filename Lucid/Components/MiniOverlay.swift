//
//  MiniOverlay.swift
//  Lucid
//
//  A lightweight, non-intrusive overlay component for displaying brief text messages.
//
//  Usage:
//    Notifier.shared.showMiniOverlay(text: "Posture check")
//    Notifier.shared.showMiniOverlay(text: "Stay hydrated")
//    Notifier.shared.showMiniOverlay(text: "Blink more")
//
//  Animation Sequence:
//    1. Small dot flies up from bottom of screen
//    2. Expands into a large circle
//    3. Expands horizontally into a pill shape with text
//    4. Holds for ~1.5 seconds
//    5. Shrinks back to circle
//    6. Shrinks to dot
//    7. Flies back down off screen
//    Total duration: ~3.15 seconds
//
//  Features:
//    - Appears on all screens simultaneously
//    - Auto-dismisses after animation completes
//    - Uses accent color from system preferences
//    - Smooth interpolated shape transitions
//

import Cocoa
import SwiftUI

class MiniOverlayHostingView: NSHostingView<MiniOverlayView> {
    weak var parentWindow: NSWindow?
}

func generateMiniOverlay(
    text: String,
    icon: String? = nil,
    screen: NSScreen,
    duration: TimeInterval = 3.15,
    holdDuration: TimeInterval = 1.5,
    backgroundColor: Color? = nil,
    foregroundColor: Color? = nil,
    verticalOffset: CGFloat = 60,
    onDismiss: @escaping () -> Void
) -> NSWindow {
    let window = NSWindow(
        contentRect: screen.frame,
        styleMask: [.borderless, .fullSizeContentView],
        backing: .buffered,
        defer: false
    )

    window.level = .floating
    window.isOpaque = false
    window.hasShadow = false
    window.ignoresMouseEvents = true
    window.backgroundColor = .clear
    window.isReleasedWhenClosed = false
    window.isMovable = false
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    let hostingView = MiniOverlayHostingView(
        rootView: MiniOverlayView(
            text: text,
            icon: icon,
            duration: duration,
            holdDuration: holdDuration,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            verticalOffset: verticalOffset,
            onDismiss: onDismiss,
            screen: screen,
            parentWindow: window
        )
    )

    hostingView.autoresizingMask = [.width, .height]
    hostingView.parentWindow = window
    window.contentView = hostingView

    return window
}

struct MiniOverlayView: View {
    let text: String
    let icon: String?
    let duration: TimeInterval
    let holdDuration: TimeInterval
    let backgroundColor: Color?
    let foregroundColor: Color?
    let verticalOffset: CGFloat
    let onDismiss: () -> Void
    let screen: NSScreen
    let parentWindow: NSWindow?

    @State private var shapeWidth: CGFloat = 8
    @State private var shapeHeight: CGFloat = 8
    @State private var textOpacity: Double = 0
    @State private var iconOpacity: Double = 0
    @State private var overallOpacity: Double = 0
    @State private var yOffset: CGFloat = 0
    @State private var isHoveringIcon = false

    private var bgColor: Color {
        backgroundColor ?? Color.accentColor
    }

    private var fgColor: Color {
        foregroundColor ?? Color.white
    }

    private let dotSize: CGFloat = 8
    private let circleSize: CGFloat = 60
    private let pillHeight: CGFloat = 60
    private let pillPadding: CGFloat = 24

    // Animation timing multiplier based on duration
    private var timeMultiplier: Double {
        duration / 3.15
    }

    // Calculate pill width based on text and icon
    private var pillWidth: CGFloat {
        let textWidth = (text as NSString).size(
            withAttributes: [.font: NSFont.systemFont(ofSize: 18, weight: .semibold)]
        ).width
        let iconWidth: CGFloat = icon != nil ? 32 : 0 // Icon + spacing
        return textWidth + iconWidth + (pillPadding * 2)
    }

    var body: some View {
        ZStack {
            VStack {
                Spacer()

                ZStack {
                    // The morphing capsule shape
                    Capsule()
                        .fill(bgColor)
                        .frame(width: shapeWidth, height: shapeHeight)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 3)
                        .shadow(color: bgColor.opacity(0.5), radius: 16, x: 0, y: 0)
                        .contentTransition(.interpolate)

                    // Text and icon that fade in/out
                    HStack(spacing: 10) {
                        if let icon = icon {
                            ZStack {
                                if isHoveringIcon {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(fgColor)
                                        .imageScale(.medium)
                                } else {
                                    Image(systemName: icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(fgColor)
                                        .imageScale(.medium)
                                }
                            }
                            .opacity(iconOpacity)
                            .onHover { hovering in
                                isHoveringIcon = hovering
                            }
                        }
                        Text(text)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(fgColor)
                            .opacity(textOpacity)
                            .fixedSize()
                    }
                }
                .frame(width: shapeWidth, height: shapeHeight)
                .contentShape(Circle())
                .onHover { hovering in
                    parentWindow?.ignoresMouseEvents = !hovering
                }
                .simultaneousGesture(TapGesture().onEnded {
                    onDismiss()
                })
                .opacity(overallOpacity)
                .offset(y: yOffset)
                .padding(.bottom, verticalOffset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Initial state: dot positioned below screen
        yOffset = 200
        overallOpacity = 1
        shapeWidth = dotSize
        shapeHeight = dotSize

        // Phase 1: Fly in from bottom as dot
        withAnimation(.easeOut(duration: 0.35 * timeMultiplier)) {
            yOffset = 0
        }

        // Phase 2: Expand to large circle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 * timeMultiplier) {
            withAnimation(.spring(response: 0.45 * timeMultiplier, dampingFraction: 0.65)) {
                shapeWidth = circleSize
                shapeHeight = circleSize
            }
        }

        // Phase 3: Expand to pill, then fade in icon and text
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75 * timeMultiplier) {
            withAnimation(.spring(response: 0.55 * timeMultiplier, dampingFraction: 0.72)) {
                shapeWidth = pillWidth
                shapeHeight = pillHeight
            }

            // Fade in icon first, then text after pill expansion starts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 * timeMultiplier) {
                withAnimation(.easeIn(duration: 0.25 * timeMultiplier)) {
                    iconOpacity = 1
                }
                // Fade in text slightly after icon
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * timeMultiplier) {
                    withAnimation(.easeIn(duration: 0.25 * timeMultiplier)) {
                        textOpacity = 1
                    }
                }
            }
        }

        // Phase 4: Hold the pill for configured duration, then fade out text and icon, then shrink to circle
        let holdDelay = 0.75 * timeMultiplier + holdDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + holdDelay) {
            withAnimation(.easeOut(duration: 0.15 * timeMultiplier)) {
                textOpacity = 0
            }
            withAnimation(.easeOut(duration: 0.15 * timeMultiplier).delay(0.05 * timeMultiplier)) {
                iconOpacity = 0
            }
            withAnimation(.spring(response: 0.35 * timeMultiplier, dampingFraction: 0.8).delay(0.15 * timeMultiplier)) {
                shapeWidth = circleSize
                shapeHeight = circleSize
            }
        }

        // Phase 5: Shrink to dot
        let shrinkDelay = holdDelay + 0.3 * timeMultiplier
        DispatchQueue.main.asyncAfter(deadline: .now() + shrinkDelay) {
            withAnimation(.spring(response: 0.3 * timeMultiplier, dampingFraction: 0.8)) {
                shapeWidth = dotSize
                shapeHeight = dotSize
            }
        }

        // Phase 6: Fly down off screen
        let flyDelay = shrinkDelay + 0.3 * timeMultiplier
        DispatchQueue.main.asyncAfter(deadline: .now() + flyDelay) {
            withAnimation(.easeIn(duration: 0.35 * timeMultiplier)) {
                yOffset = 200
            }
        }

        // Phase 7: Dismiss
        let dismissDelay = flyDelay + 0.35 * timeMultiplier
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) {
            onDismiss()
        }
    }
}
