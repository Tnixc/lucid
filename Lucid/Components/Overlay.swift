import Cocoa
import SwiftUI

func generateOverlay(
    title: String,
    message: String,
    seconds: Double,
    screen: NSScreen,
    autoDismiss: Bool = true,
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
    window.ignoresMouseEvents = false
    window.backgroundColor = .clear
    window.isReleasedWhenClosed = false
    window.isMovable = false
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    let contentView = NSHostingView(
        rootView: OverlayView(
            title: title,
            message: message,
            duration: seconds,
            autoDismiss: autoDismiss,
            onDismiss: onDismiss
        )
    )

    contentView.autoresizingMask = [.width, .height]
    window.contentView = contentView

    return window
}

struct OverlayView: View {
    let title: String
    let message: String
    let autoDismiss: Bool
    let onDismiss: () -> Void
    @State private var remainingTime: TimeInterval
    @State private var currentTime: String = ""
    @State private var visibleButtonIndex: Int
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var hasAppeared = false

    private let defaults = UserDefaults.standard

    private var clickToDismiss: Bool {
        defaults.object(forKey: "eyeStrainClickToDismiss") as? Bool ?? true
    }

    private var overlayMaterial: NSVisualEffectView.Material {
        let materialString =
            defaults.string(forKey: "overlayMaterial") ?? "Medium"
        switch materialString {
        case "Ultra Thin": return .hudWindow
        case "Thin": return .sidebar
        case "Medium": return .popover
        case "Thick": return .headerView
        case "Ultra Thick": return .sheet
        default: return .sidebar
        }
    }

    init(
        title: String,
        message: String,
        duration: TimeInterval,
        autoDismiss: Bool = true,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.autoDismiss = autoDismiss
        self.onDismiss = onDismiss
        _remainingTime = State(initialValue: duration)
        _visibleButtonIndex = State(initialValue: Int.random(in: 0 ..< 12))
    }

    func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func updateCurrentTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        currentTime = formatter.string(from: Date())
    }

    var body: some View {
        var view = AnyView(
            ZStack {
                VisualEffectView(
                    material: overlayMaterial,
                    blendingMode: .behindWindow
                )

                VStack(spacing: 0) {
                    Spacer()

                    // Centered content with clock above
                    VStack(spacing: 30) {
                        Text("The time is " + currentTime)
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 20) {
                            Text(title)
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text(message)
                                .font(.title2)

                            if autoDismiss {
                                HStack(spacing: 0) {
                                    Text("Dismisses in ")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                    Text(formatTime(remainingTime))
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                        .contentTransition(
                                            .numericText(countsDown: true)
                                        )
                                        .animation(.snappy, value: remainingTime)
                                        .monospacedDigit()
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()

                // Top edge buttons (indices 0-2)
                VStack {
                    HStack {
                        Spacer()
                        if visibleButtonIndex == 0 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                        if visibleButtonIndex == 1 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                        if visibleButtonIndex == 2 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                    }
                    .padding(.top, 40)
                    Spacer()
                }

                // Bottom edge buttons (indices 3-5)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if visibleButtonIndex == 3 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                        if visibleButtonIndex == 4 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                        if visibleButtonIndex == 5 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                    }
                    .padding(.bottom, 40)
                }

                // Left edge buttons (indices 6-8)
                HStack {
                    VStack {
                        Spacer()
                        if visibleButtonIndex == 6 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                        if visibleButtonIndex == 7 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                        if visibleButtonIndex == 8 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                    }
                    .padding(.leading, 40)
                    Spacer()
                }

                // Right edge buttons (indices 9-11)
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        if visibleButtonIndex == 9 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                        if visibleButtonIndex == 10 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                        if visibleButtonIndex == 11 {
                            UIButton(
                                action: { onDismiss() },
                                label: "Skip",
                                icon: "chevron.forward.dotted.chevron.forward",
                                width: 120
                            )
                        }
                        Spacer()
                    }
                    .padding(.trailing, 40)
                }
            }
            .onAppear {
                hasAppeared = true
                updateCurrentTime()
            }
            .onReceive(timer) { _ in
                guard hasAppeared else { return }
                updateCurrentTime()
                if autoDismiss {
                    if remainingTime > 0 {
                        remainingTime -= 1
                    } else {
                        hasAppeared = false
                        onDismiss()
                    }
                }
            }
        )

        if clickToDismiss {
            view = AnyView(
                view.onTapGesture {
                    onDismiss()
                }
            )
        }

        return view
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context _: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        visualEffectView.isEmphasized = true
        return visualEffectView
    }

    func updateNSView(
        _ visualEffectView: NSVisualEffectView,
        context _: Context
    ) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
