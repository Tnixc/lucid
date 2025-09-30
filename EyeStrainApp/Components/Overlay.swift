import SwiftUI

func generateOverlay(
    title: String,
    message: String,
    seconds: Double,
    screen: NSScreen,
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

    let contentView = NSHostingView(
        rootView: OverlayView(
            title: title,
            message: message,
            duration: seconds,
            onDismiss: onDismiss
        )
    )

    contentView.frame = window.contentView!.bounds
    contentView.autoresizingMask = [.width, .height]
    window.contentView?.addSubview(contentView)

    return window
}

struct OverlayView: View {
    let title: String
    let message: String
    let onDismiss: () -> Void
    @State private var remainingTime: TimeInterval

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
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.onDismiss = onDismiss
        _remainingTime = State(initialValue: duration)
    }

    func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        var view = AnyView(
            ZStack {
                VisualEffectView(
                    material: overlayMaterial,
                    blendingMode: .behindWindow
                )

                VStack(spacing: 20) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(message)
                        .font(.title2)

                    HStack(spacing: 0) {
                        Text("Dismisses in ")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text(formatTime(remainingTime))
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText(countsDown: true))
                            .animation(.snappy, value: remainingTime)
                            .monospacedDigit()
                    }
                }
                .padding()
            }
            .onAppear {
                startTimer(interval: 1)
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

    private func startTimer(interval: Double) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {
            timer in
            if remainingTime > 0 {
                remainingTime -= interval
            } else {
                timer.invalidate()
                onDismiss()
            }
        }
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
