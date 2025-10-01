import KeyboardShortcuts
import ServiceManagement
import SwiftUI

enum OverlayMaterial: String, CaseIterable, Hashable {
    case ultraThin = "Ultra Thin"
    case thin = "Thin"
    case medium = "Medium"
    case thick = "Thick"
    case ultraThick = "Ultra Thick"

    var nsMaterial: NSVisualEffectView.Material {
        switch self {
        case .ultraThin: return .hudWindow
        case .thin: return .toolTip
        case .medium: return .fullScreenUI
        case .thick: return .sheet
        case .ultraThick: return .windowBackground
        }
    }

    static func fromString(_ string: String) -> OverlayMaterial {
        return OverlayMaterial.allCases.first { $0.rawValue == string }
            ?? .medium
    }
}

struct GeneralSettingsTab: View {
    @State private var launchAtLogin: Bool
    @State private var overlayMaterial: OverlayMaterial
    @State private var clickToDismiss: Bool

    init() {
        let defaults = UserDefaults.standard
        _launchAtLogin = State(
            initialValue: defaults.bool(forKey: "launchAtLogin")
        )
        let materialString =
            defaults.string(forKey: "overlayMaterial") ?? "Medium"
        _overlayMaterial = State(
            initialValue: OverlayMaterial.fromString(materialString)
        )
        _clickToDismiss = State(
            initialValue: defaults.object(forKey: "eyeStrainClickToDismiss")
                as? Bool ?? true
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Style.Layout.padding) {
            Text("General").font(.title).padding()

            SettingItem(
                title: "Launch at Login",
                description:
                "Automatically start Lucid when you log in.",
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

            SettingItem(
                title: "Overlay Opacity",
                description: "Material thickness for overlay background.",
                icon: "circle.lefthalf.filled"
            ) {
                UIDropdown(
                    selectedOption: overlayMaterialBinding,
                    options: OverlayMaterial.allCases,
                    optionToString: { $0.rawValue },
                    width: 150,
                    height: 40
                )
            }
            .zIndex(100)

            SettingItem(
                title: "Click to Dismiss",
                description:
                "Allow clicking on the overlay to dismiss it. Not recommened.",
                icon: "hand.tap"
            ) {
                Toggle("", isOn: clickToDismissBinding)
                    .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                    .scaleEffect(0.9, anchor: .trailing)
            }

            SettingItem(
                title: "Preview",
                description: "Test the overlay with current opacity setting.",
                icon: "eye"
            ) {
                UIButton(
                    action: {
                        Notifier.shared.showOverlay(
                            title: "Overlay Preview",
                            message:
                            "This is how your overlays will look with the current opacity setting.",
                            dismissAfter: 5.0,
                            isPreview: true
                        )
                    },
                    label: "Preview",
                    width: 120
                )
            }

            InfoBox {
                HStack {
                    Image(systemName: "info.circle.fill")
                    Text("The skip button is randomly placed to prevent developing muscle memory.")
                    Spacer()
                }
            }
            Spacer()
            InfoBox {
                HStack {
                    Image(systemName: "info.circle.fill")
                    Text("Questions/bugs? Email me at enochlauenoch@gmail.com")
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

    private var overlayMaterialBinding: Binding<OverlayMaterial> {
        Binding(
            get: { self.overlayMaterial },
            set: {
                self.overlayMaterial = $0
                UserDefaults.standard.set(
                    $0.rawValue,
                    forKey: "overlayMaterial"
                )
            }
        )
    }

    private var clickToDismissBinding: Binding<Bool> {
        Binding(
            get: { self.clickToDismiss },
            set: {
                self.clickToDismiss = $0
                UserDefaults.standard.set($0, forKey: "eyeStrainClickToDismiss")
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
