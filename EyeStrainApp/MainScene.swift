import SettingsAccess
import SwiftUI

struct MainScene: Scene {
    var body: some Scene {
        Window("Eye Strain Settings", id: "settings") {
            SettingsWindow()
                .background(VisualEffect().ignoresSafeArea())
                .frame(
                    minWidth: 800,
                    minHeight: 500
                )
                .toolbar { Text("Eye Strain Settings").fontWeight(.bold).font(.title3) }
        }
        .windowResizability(WindowResizability.contentSize)
        .defaultSize(
            width: 800,
            height: 500
        )
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
    }
}

struct VisualEffect: NSViewRepresentable {
    func makeNSView(context _: Self.Context) -> NSView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .menu
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = NSVisualEffectView.State.active
        visualEffectView.isEmphasized = true
        return visualEffectView
    }

    func updateNSView(_: NSView, context _: Context) {}
}
