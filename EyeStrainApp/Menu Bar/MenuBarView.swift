import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var menuBarModel: MenuBarModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 16) {
            // Main Status Card
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Large icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                Style.Colors.barFill
                            ).opacity(0.3)
                            .frame(width: 52, height: 52)

                        Image(systemName: "eye.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Break")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        Text(menuBarModel.countdown)
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.primary)
                            .monospacedDigit()
                    }

                    Spacer()
                }
                .padding(16)
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
