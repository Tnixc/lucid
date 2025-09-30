import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var menuBarModel: MenuBarModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: Style.Layout.padding) {
            VStack(alignment: .leading, spacing: Style.Layout.padding) {
                HStack {
                    Image(systemName: "eye").font(.title)
                        .padding(.trailing, Style.Layout.paddingSM)
                    VStack(alignment: .leading) {
                        Text("Next Break:").foregroundStyle(.secondary).font(.caption)
                        Text(menuBarModel.countdown).font(.title2)
                    }
                    Spacer()
                }

                Divider()

                VStack(spacing: Style.Layout.paddingSM) {
                    UIButton(
                        action: {
                            menuBarModel.resetTimer()
                        },
                        label: "Reset Timer",
                        height: Style.Button.heightSM
                    )
                }
            }

            Divider()

            HStack(spacing: Style.Layout.padding) {
                UIButton(
                    action: {
                        NSApp.activate(ignoringOtherApps: true)
                        openWindow(id: "settings")
                    },
                    label: "Settings",
                    height: Style.Button.heightSM
                )
                UIButton(
                    action: {
                        NSApplication.shared.terminate(nil)
                    },
                    label: "Quit",
                    icon: "xmark",
                    height: Style.Button.heightSM
                )
            }
        }
        .padding(Style.Layout.padding)
        .background(VisualEffect().ignoresSafeArea())
    }
}
