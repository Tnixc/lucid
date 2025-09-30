import SwiftUI

func keyCodeFromString(_ string: String) -> UInt16? {
    switch string.lowercased() {
    case "escape": return 53
    case "space": return 49
    case "return": return 36
    case "enter": return 36
    case "tab": return 48
    case "delete": return 51
    case "backspace": return 51
    case "a": return 0
    case "b": return 11
    case "c": return 8
    case "d": return 2
    case "e": return 14
    case "f": return 3
    case "g": return 5
    case "h": return 4
    case "i": return 34
    case "j": return 38
    case "k": return 40
    case "l": return 37
    case "m": return 46
    case "n": return 45
    case "o": return 31
    case "p": return 35
    case "q": return 12
    case "r": return 15
    case "s": return 1
    case "t": return 17
    case "u": return 32
    case "v": return 9
    case "w": return 13
    case "x": return 7
    case "y": return 16
    case "z": return 6
    default: return nil
    }
}

func generateOverlay(
    title: String,
    message: String,
    seconds: Double,
    onDismiss: @escaping () -> Void,
    hotkeyKey _: String
) -> NSWindow {
    let screen = NSScreen.main!
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

    private var clickToDismiss: Bool { defaults.object(forKey: "eyeStrainClickToDismiss") as? Bool ?? true }

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
                VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)

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
                            .animation(.bouncy, value: remainingTime).monospacedDigit()
                    }
                }
                .padding()
            }
            .onAppear {
                startTimer(interval: 1)
            }
        )

        if clickToDismiss {
            view = AnyView(view.onTapGesture {
                onDismiss()
            })
        }

        return view
    }

    private func startTimer(interval: Double) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
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

    func updateNSView(_ visualEffectView: NSVisualEffectView, context _: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
