//
//  MiniOverlay.swift
//  EyeStrainApp
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
//    - Non-interactive (ignores mouse events)
//    - Auto-dismisses after animation completes
//    - Uses accent color from system preferences
//    - Smooth interpolated shape transitions
//

import Cocoa
import SwiftUI

func generateMiniOverlay(
    text: String,
    screen: NSScreen,
    duration: TimeInterval = 3.15,
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

    let contentView = NSHostingView(
        rootView: MiniOverlayView(
            text: text,
            duration: duration,
            onDismiss: onDismiss
        )
    )

    contentView.frame = window.contentView!.bounds
    contentView.autoresizingMask = [.width, .height]
    window.contentView?.addSubview(contentView)

    return window
}

struct MiniOverlayView: View {
    let text: String
    let duration: TimeInterval
    let onDismiss: () -> Void
    
    @State private var shapeWidth: CGFloat = 8
    @State private var shapeHeight: CGFloat = 8
    @State private var textOpacity: Double = 0
    @State private var overallOpacity: Double = 0
    @State private var yOffset: CGFloat = 0
    
    private let dotSize: CGFloat = 8
    private let circleSize: CGFloat = 60
    private let pillHeight: CGFloat = 60
    private let pillPadding: CGFloat = 24
    
    // Animation timing multiplier based on duration
    private var timeMultiplier: Double {
        duration / 3.15
    }
    
    // Calculate pill width based on text
    private var pillWidth: CGFloat {
        let textWidth = (text as NSString).size(
            withAttributes: [.font: NSFont.systemFont(ofSize: 18, weight: .semibold)]
        ).width
        return textWidth + (pillPadding * 2)
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                ZStack {
                    // The morphing capsule shape
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: shapeWidth, height: shapeHeight)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 3)
                        .shadow(color: Color.accentColor.opacity(0.5), radius: 16, x: 0, y: 0)
                        .contentTransition(.interpolate)
                    
                    // Text that fades in/out
                    Text(text)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                        .contentTransition(.interpolate)
                }
                .opacity(overallOpacity)
                .offset(y: yOffset)
                .padding(.bottom, 200)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
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
        
        // Phase 3: Expand to pill with text fade in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75 * timeMultiplier) {
            withAnimation(.spring(response: 0.55 * timeMultiplier, dampingFraction: 0.72)) {
                shapeWidth = pillWidth
                shapeHeight = pillHeight
            }
            withAnimation(.easeIn(duration: 0.3 * timeMultiplier)) {
                textOpacity = 1
            }
        }
        
        // Phase 4: Fade out text and shrink to circle
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2 * timeMultiplier) {
            withAnimation(.easeOut(duration: 0.2 * timeMultiplier)) {
                textOpacity = 0
            }
            withAnimation(.spring(response: 0.35 * timeMultiplier, dampingFraction: 0.8).delay(0.1 * timeMultiplier)) {
                shapeWidth = circleSize
                shapeHeight = circleSize
            }
        }
        
        // Phase 5: Shrink to dot
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 * timeMultiplier) {
            withAnimation(.spring(response: 0.3 * timeMultiplier, dampingFraction: 0.8)) {
                shapeWidth = dotSize
                shapeHeight = dotSize
            }
        }
        
        // Phase 6: Fly down off screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8 * timeMultiplier) {
            withAnimation(.easeIn(duration: 0.35 * timeMultiplier)) {
                yOffset = 200
            }
        }
        
        // Phase 7: Dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.15 * timeMultiplier) {
            onDismiss()
        }
    }
}
