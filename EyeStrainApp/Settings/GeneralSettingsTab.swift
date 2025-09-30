import KeyboardShortcuts
import ServiceManagement
import SwiftUI

struct GeneralSettingsTab: View {
    @State private var launchAtLogin: Bool

    init() {
        let defaults = UserDefaults.standard
        _launchAtLogin = State(initialValue: defaults.bool(forKey: "launchAtLogin"))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Style.Layout.padding) {
            Text("General").font(.title).padding()

            SettingItem(
                title: "Launch at Login",
                description: "Automatically start Eye Strain App when you log in.",
                icon: "power"
            ) {
                Toggle("", isOn: launchAtLoginBinding)
                    .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                    .scaleEffect(0.9, anchor: .trailing)
            }

            SettingItem(
                title: "Dismiss Overlay Hotkey",
                description: "Keyboard shortcut to dismiss any overlay.",
                icon: "keyboard"
            ) {
                KeyboardShortcuts.Recorder(for: .dismissOverlay)
            }

            Spacer()
            InfoBox {
                HStack {
                    Image(systemName: "hand.raised.slash")
                    Text("Eye Strain App is designed for your privacy. No data leaves your device.")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { self.launchAtLogin },
            set: {
                self.launchAtLogin = $0
                UserDefaults.standard.set($0, forKey: "launchAtLogin")
                self.setLaunchAtLogin($0)
            }
        )
    }

    private func setLaunchAtLogin(_ enable: Bool) {
        if enable {
            try? SMAppService.mainApp.register()
        } else {
            try? SMAppService.mainApp.unregister()
        }
    }
}

extension UserDefaults {
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            set(defaultValue, forKey: key)
        }
        return bool(forKey: key)
    }
}
