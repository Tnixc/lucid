import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var menuBarModel: MenuBarModel
    @Environment(\.openWindow) private var openWindow
    @AppStorage("alertsEnabled") private var alertsEnabled: Bool = true

    var body: some View {
        VStack(spacing: 16) {
            // Timers Card
            VStack(spacing: 0) {
                TimerRow(
                    icon: "eye.fill",
                    label: "Eye Strain Break",
                    countdown: menuBarModel.eyeStrainCountdown,
                    enabled: menuBarModel.eyeStrainEnabled
                )
                
                Divider()
                    .padding(.horizontal, 16)
                
                TimerRow(
                    icon: "moon.fill",
                    label: "Bedtime",
                    countdown: menuBarModel.bedtimeCountdown,
                    enabled: menuBarModel.bedtimeEnabled
                )
                
                Divider()
                    .padding(.horizontal, 16)
                
                TimerRow(
                    icon: "sparkles",
                    label: "Mini Reminder",
                    countdown: menuBarModel.miniOverlayCountdown,
                    enabled: menuBarModel.miniOverlayEnabled
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
            )

            // Action Card
            VStack(spacing: 0) {
                ControlCenterButton(
                    icon: "arrow.counterclockwise",
                    label: "Reset Timer",
                    action: {
                        menuBarModel.resetTimer()
                    }
                )

                Divider()
                    .padding(.horizontal, 12)

                ControlCenterToggle(
                    icon: alertsEnabled ? "bell.fill" : "bell.slash.fill",
                    label: "All Alerts",
                    isOn: $alertsEnabled
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
            )

            // Bottom Actions
            HStack(spacing: 12) {
                ControlCenterIconButton(
                    icon: "gearshape.fill",
                    action: {
                        NSApp.activate(ignoringOtherApps: true)
                        openWindow(id: "settings")
                    }
                )

                Spacer()

                ControlCenterIconButton(
                    icon: "xmark",
                    action: {
                        NSApplication.shared.terminate(nil)
                    },
                    destructive: true
                )
            }
        }
        .padding(16)
        .frame(width: 280)
        .background(
            VisualEffect()
                .ignoresSafeArea()
        )
    }
}

// MARK: - Timer Row Component

struct TimerRow: View {
    let icon: String
    let label: String
    let countdown: String
    let enabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(enabled ? Color.secondary.opacity(0.4) : Color.secondary.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(enabled ? .white : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(enabled ? .primary : .secondary)
                
                if !enabled {
                    Text("Disabled")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Text(countdown)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(enabled ? .primary : .secondary)
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .opacity(enabled ? 1.0 : 0.5)
    }
}

// MARK: - Control Center Button Component

struct ControlCenterButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 24, height: 24)

                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .focusable(false)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Control Center Icon Button Component

struct ControlCenterIconButton: View {
    let icon: String
    let action: () -> Void
    var destructive: Bool = false

    @State private var isHovered = false
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        destructive
                            ? (isHovered
                                ? Color.red.opacity(0.15)
                                : Color.secondary.opacity(0.08))
                            : (isHovered
                                ? Color.primary.opacity(0.12)
                                : Color.secondary.opacity(0.08))
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                destructive && isHovered
                                    ? Color.red.opacity(0.3)
                                    : Color.white.opacity(
                                        isHovered ? 0.25 : 0.15
                                    ),
                                lineWidth: 1
                            )
                    )

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(destructive && isHovered ? .red : .primary)
            }
            .frame(width: 44, height: 44)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .focusable(false)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .pressEvents(
            onPress: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
            },
            onRelease: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        )
    }
}

// MARK: - Control Center Toggle Component

struct ControlCenterToggle: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool

    @State private var isHovered = false

    var body: some View {
        Button(action: {
            isOn.toggle()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isOn ? .primary : .secondary)
                    .frame(width: 24, height: 24)

                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isOn ? .primary : .secondary)

                Spacer()

                Toggle("", isOn: $isOn)
                    .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                    .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .focusable(false)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Press Events Modifier

extension View {
    func pressEvents(
        onPress: @escaping () -> Void,
        onRelease: @escaping () -> Void
    ) -> some View {
        simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    onPress()
                }
                .onEnded { _ in
                    onRelease()
                }
        )
    }
}
