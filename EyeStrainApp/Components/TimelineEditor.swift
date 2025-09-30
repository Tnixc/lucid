// TimelineEditor.swift

import AppKit
import SwiftUI

// Custom numeric text field for better input handling
struct NumericTextField: NSViewRepresentable {
    @Binding var value: Int
    let range: ClosedRange<Int>

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.stringValue = "\(value)"
        textField.alignment = .center
        textField.font = .systemFont(ofSize: 11)
        textField.delegate = context.coordinator
        textField.focusRingType = .none
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if !context.coordinator.isEditing {
            nsView.stringValue = String(format: "%02d", value)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: NumericTextField
        var isEditing = false

        init(_ parent: NumericTextField) {
            self.parent = parent
        }

        func controlTextDidBeginEditing(_: Notification) {
            isEditing = true
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            isEditing = false
            if let textField = obj.object as? NSTextField {
                if let intValue = Int(textField.stringValue) {
                    parent.value = max(
                        parent.range.lowerBound,
                        min(parent.range.upperBound, intValue)
                    )
                }
                textField.stringValue = String(format: "%02d", parent.value)
            }
        }

        func control(
            _ control: NSControl,
            textView _: NSTextView,
            doCommandBy commandSelector: Selector
        ) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                control.window?.makeFirstResponder(nil)
                return true
            }
            return false
        }
    }
}

struct TimelineEditor: View {
    @Binding var startHour: Int
    @Binding var startMinute: Int
    @Binding var endHour: Int
    @Binding var endMinute: Int

    @State private var isDraggingStart = false
    @State private var isDraggingEnd = false
    @State private var lastHapticMinute: Int?

    private let timelineHeight: CGFloat = 60
    private let handleWidth: CGFloat = 8
    private let handleHeight: CGFloat = 60
    private static let totalHours = 24

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Time labels
            GeometryReader { geometry in
                let width = geometry.size.width
                ZStack(alignment: .leading) {
                    ForEach(0 ..< 25) { hour in
                        Text("\(hour)")
                            .font(.caption2)
                            .monospacedDigit()
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                            .offset(x: (CGFloat(hour) / 24.0) * width - 10)
                    }
                }
            }
            .frame(height: 16)

            // Timeline bar with handles
            GeometryReader { geometry in
                let width = geometry.size.width

                ZStack(alignment: .leading) {
                    // Background timeline
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                        .frame(height: timelineHeight)

                    // Hour markers
                    ZStack(alignment: .leading) {
                        ForEach(1 ..< 24) { hour in
                            Rectangle()
                                .fill(
                                    Color(nsColor: .separatorColor).opacity(
                                        hour % 6 == 0 ? 0.6 : 0.3
                                    )
                                )
                                .frame(width: 1, height: timelineHeight)
                                .offset(x: (CGFloat(hour) / 24.0) * width)
                        }
                    }

                    // Active period bar
                    activeBar(width: width)

                    // Start handle (night - blue)
                    handle(
                        hour: startHour,
                        minute: startMinute,
                        width: width,
                        isDragging: isDraggingStart,
                        color: Style.Colors.nightTime
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDraggingStart = true
                                updateTime(
                                    x: value.location.x,
                                    width: width,
                                    isStart: true
                                )
                            }
                            .onEnded { _ in
                                isDraggingStart = false
                                lastHapticMinute = nil
                            }
                    )

                    // End handle (morning - orange)
                    handle(
                        hour: endHour,
                        minute: endMinute,
                        width: width,
                        isDragging: isDraggingEnd,
                        color: Style.Colors.morningTime
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDraggingEnd = true
                                updateTime(
                                    x: value.location.x,
                                    width: width,
                                    isStart: false
                                )
                            }
                            .onEnded { _ in
                                isDraggingEnd = false
                                lastHapticMinute = nil
                            }
                    )
                }
                .frame(height: timelineHeight)
            }
            .frame(height: timelineHeight)

            // Time display with text inputs
            HStack(spacing: 16) {
                // Start time input
                HStack(spacing: 8) {
                    Image(systemName: "moon.fill")
                        .foregroundColor(Style.Colors.nightTime)
                        .font(.caption)

                    HStack(spacing: 4) {
                        NumericTextField(value: startHourBinding, range: 0 ... 23)
                            .frame(width: 35, height: 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                            )

                        Text(":")
                            .foregroundColor(.secondary)
                            .monospacedDigit()

                        NumericTextField(value: startMinuteBinding, range: 0 ... 59)
                            .frame(width: 35, height: 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                            )
                    }

                    Text(formatTime(hour: startHour, minute: startMinute))
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText())
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                // End time input
                HStack(spacing: 8) {
                    Image(systemName: "sunrise.fill")
                        .foregroundColor(Style.Colors.morningTime)
                        .font(.caption)

                    HStack(spacing: 4) {
                        NumericTextField(value: endHourBinding, range: 0 ... 23)
                            .frame(width: 35, height: 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                            )

                        Text(":")
                            .foregroundColor(.secondary)
                            .monospacedDigit()

                        NumericTextField(value: endMinuteBinding, range: 0 ... 59)
                            .frame(width: 35, height: 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                            )
                    }

                    Text(formatTime(hour: endHour, minute: endMinute))
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText())
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var startHourBinding: Binding<Int> {
        Binding(
            get: { self.startHour },
            set: { newValue in
                self.startHour = max(0, min(23, newValue))
            }
        )
    }

    private var startMinuteBinding: Binding<Int> {
        Binding(
            get: { self.startMinute },
            set: { newValue in
                self.startMinute = max(0, min(59, newValue))
            }
        )
    }

    private var endHourBinding: Binding<Int> {
        Binding(
            get: { self.endHour },
            set: { newValue in
                self.endHour = max(0, min(23, newValue))
            }
        )
    }

    private var endMinuteBinding: Binding<Int> {
        Binding(
            get: { self.endMinute },
            set: { newValue in
                self.endMinute = max(0, min(59, newValue))
            }
        )
    }

    private func activeBar(width: CGFloat) -> some View {
        let startPosition = position(
            hour: startHour,
            minute: startMinute,
            width: width
        )
        let endPosition = position(hour: endHour, minute: endMinute, width: width)
        let handleRadius = handleWidth / 2

        // Handle wrapping around midnight
        let wrapsAround = endPosition < startPosition

        return ZStack(alignment: .leading) {
            if wrapsAround {
                // Two bars: start to end of timeline, and beginning to end

                // From start to end of timeline
                UnevenRoundedRectangle(
                    topLeadingRadius: handleRadius,
                    bottomLeadingRadius: handleRadius,
                    bottomTrailingRadius: 8,
                    topTrailingRadius: 8
                )
                .fill(
                    Gradient(colors: [Style.Colors.nightTime, Style.Colors.morningTime]).opacity(0.3)
                )
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: handleRadius,
                        bottomLeadingRadius: handleRadius,
                        bottomTrailingRadius: 8,
                        topTrailingRadius: 8
                    )
                    .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
                )
                .frame(width: width - startPosition, height: timelineHeight)
                .offset(x: startPosition)

                // From beginning to end position
                UnevenRoundedRectangle(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: handleRadius,
                    topTrailingRadius: handleRadius
                )
                .fill(Style.Colors.barFill.opacity(0.3))
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 8,
                        bottomLeadingRadius: 8,
                        bottomTrailingRadius: handleRadius,
                        topTrailingRadius: handleRadius
                    )
                    .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
                )
                .frame(width: endPosition, height: timelineHeight)
                .offset(x: 0)
            } else {
                // Single bar from start to end
                UnevenRoundedRectangle(
                    topLeadingRadius: handleRadius,
                    bottomLeadingRadius: handleRadius,
                    bottomTrailingRadius: handleRadius,
                    topTrailingRadius: handleRadius
                )
                .fill(Style.Colors.barFill.opacity(0.3))
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: handleRadius,
                        bottomLeadingRadius: handleRadius,
                        bottomTrailingRadius: handleRadius,
                        topTrailingRadius: handleRadius
                    )
                    .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
                )
                .frame(width: endPosition - startPosition, height: timelineHeight)
                .offset(x: startPosition)
            }
        }
        .frame(width: width, height: timelineHeight, alignment: .leading)
    }

    private func handle(
        hour: Int,
        minute: Int,
        width: CGFloat,
        isDragging: Bool,
        color: Color
    ) -> some View {
        let xPosition = position(hour: hour, minute: minute, width: width)

        return VStack(spacing: 2) {
            // Time label above handle
            Text(formatTime(hour: hour, minute: minute))
                .font(.system(size: 10, weight: .semibold))
                .monospacedDigit()
                .animation(.snappy)
                .contentTransition(.numericText())
                .foregroundColor(Color.primary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(color.opacity(0.4), lineWidth: 1)
                        )
                )
                .opacity(isDragging ? 1 : 0)
                .offset(y: -40)

            // Handle pill
            Capsule()
                .fill(color)
                .frame(width: handleWidth, height: handleHeight)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.5), radius: isDragging ? 6 : 3)
                .scaleEffect(isDragging ? 1.2 : 1.0)
                .animation(.spring(response: 0.3), value: isDragging)
                .offset(y: -10)
        }
        .offset(x: (xPosition - handleWidth / 2) - 26)
        .frame(height: timelineHeight, alignment: .center)
    }

    private func position(hour: Int, minute: Int, width: CGFloat) -> CGFloat {
        let totalMinutes = Double(hour * 60 + minute)
        let totalTimelineMinutes = Double(Self.totalHours * 60)
        return (totalMinutes / totalTimelineMinutes) * width
    }

    private func updateTime(x: CGFloat, width: CGFloat, isStart: Bool) {
        let clampedX = max(0, min(x, width))
        let ratio = clampedX / width
        let totalMinutes = Int(ratio * Double(Self.totalHours * 60))

        let hour = totalMinutes / 60
        let minute = (totalMinutes % 60 / 15) * 15 // Snap to 15-minute intervals

        // Trigger haptic feedback when crossing a 15-minute boundary
        let currentSnapMinute = hour * 60 + minute
        if let lastMinute = lastHapticMinute, lastMinute != currentSnapMinute {
            NSHapticFeedbackManager.defaultPerformer.perform(
                .alignment,
                performanceTime: .now
            )
        }
        lastHapticMinute = currentSnapMinute

        if isStart {
            startHour = hour
            startMinute = minute
        } else {
            endHour = hour
            endMinute = minute
        }
    }

    private func formatTime(hour: Int, minute: Int) -> String {
        let period = hour < 12 ? "AM" : "PM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }
}

struct TimelineEditor_Previews: PreviewProvider {
    static var previews: some View {
        TimelineEditor(
            startHour: .constant(22),
            startMinute: .constant(0),
            endHour: .constant(6),
            endMinute: .constant(0)
        )
        .padding()
        .frame(width: 600)
    }
}
