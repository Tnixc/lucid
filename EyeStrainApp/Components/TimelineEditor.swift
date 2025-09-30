// TimelineEditor.swift

import SwiftUI

struct TimelineEditor: View {
    @Binding var startHour: Int
    @Binding var startMinute: Int
    @Binding var endHour: Int
    @Binding var endMinute: Int
    
    @State private var isDraggingStart = false
    @State private var isDraggingEnd = false
    
    private let timelineHeight: CGFloat = 60
    private let handleWidth: CGFloat = 8
    private let handleHeight: CGFloat = 50
    private static let totalHours = 24
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Time labels
            HStack(spacing: 0) {
                ForEach(0..<24) { hour in
                    Text("\(hour)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Timeline bar with handles
            GeometryReader { geometry in
                let width = geometry.size.width
                
                ZStack(alignment: .leading) {
                    // Background timeline
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: timelineHeight)
                    
                    // Hour markers
                    HStack(spacing: 0) {
                        ForEach(0..<24) { hour in
                            Rectangle()
                                .fill(Color.secondary.opacity(hour % 6 == 0 ? 0.3 : 0.15))
                                .frame(width: 1, height: timelineHeight)
                                .frame(maxWidth: .infinity)
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
                        color: .blue
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
                            }
                    )
                    
                    // End handle (morning - orange)
                    handle(
                        hour: endHour,
                        minute: endMinute,
                        width: width,
                        isDragging: isDraggingEnd,
                        color: .orange
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
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    HStack(spacing: 4) {
                        TextField("", value: $startHour, format: .number)
                            .frame(width: 30)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .onChange(of: startHour) { newValue in
                                startHour = max(0, min(23, newValue))
                            }
                        
                        Text(":")
                            .foregroundColor(.secondary)
                        
                        TextField("", value: $startMinute, format: .number)
                            .frame(width: 30)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .onChange(of: startMinute) { newValue in
                                startMinute = max(0, min(59, newValue))
                            }
                    }
                    
                    Text(formatTime(hour: startHour, minute: startMinute))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // End time input
                HStack(spacing: 8) {
                    Image(systemName: "sunrise.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    HStack(spacing: 4) {
                        TextField("", value: $endHour, format: .number)
                            .frame(width: 30)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .onChange(of: endHour) { newValue in
                                endHour = max(0, min(23, newValue))
                            }
                        
                        Text(":")
                            .foregroundColor(.secondary)
                        
                        TextField("", value: $endMinute, format: .number)
                            .frame(width: 30)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                            .onChange(of: endMinute) { newValue in
                                endMinute = max(0, min(59, newValue))
                            }
                    }
                    
                    Text(formatTime(hour: endHour, minute: endMinute))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func activeBar(width: CGFloat) -> some View {
        let startPosition = position(hour: startHour, minute: startMinute, width: width)
        let endPosition = position(hour: endHour, minute: endMinute, width: width)
        
        // Handle wrapping around midnight
        let wrapsAround = endPosition < startPosition
        
        return Group {
            if wrapsAround {
                // Two bars: start to end of timeline, and beginning to end
                ZStack(alignment: .leading) {
                    // From start to end of timeline
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.3),
                                    Color.purple.opacity(0.3)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width - startPosition, height: timelineHeight)
                        .offset(x: startPosition)
                    
                    // From beginning to end position
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.3),
                                    Color.blue.opacity(0.3)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: endPosition, height: timelineHeight)
                }
            } else {
                // Single bar from start to end
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.3)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: endPosition - startPosition, height: timelineHeight)
                    .offset(x: startPosition)
            }
        }
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
                .foregroundColor(color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                )
                .opacity(isDragging ? 1 : 0)
                .offset(y: -30)
            
            // Handle pill
            Capsule()
                .fill(color)
                .frame(width: handleWidth, height: handleHeight)
                .overlay(
                    Capsule()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: color.opacity(0.3), radius: isDragging ? 8 : 4)
                .scaleEffect(isDragging ? 1.15 : 1.0)
                .animation(.spring(response: 0.3), value: isDragging)
        }
        .offset(x: xPosition - handleWidth / 2)
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
