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
    @State private var soundEffectsEnabled: Bool
    @State private var reminderSoundEffect: String
    @State private var soundEffectsVolume: Double
    @State private var disableDuringPresentation: Bool
    @State private var useCustomColors: Bool
    @State private var overlayTextColor: Color
    @State private var overlayBackgroundColor: Color

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
        _soundEffectsEnabled = State(
            initialValue: defaults.bool(forKey: "soundEffectsEnabled")
        )
        _reminderSoundEffect = State(
            initialValue: defaults.string(forKey: "reminderSoundEffect") ?? "Ping"
        )
        _soundEffectsVolume = State(
            initialValue: defaults.double(forKey: "soundEffectsVolume") != 0
                ? defaults.double(forKey: "soundEffectsVolume")
                : 0.5
        )
        _disableDuringPresentation = State(
            initialValue: defaults.object(forKey: "disableDuringPresentation") as? Bool ?? true
        )

        _useCustomColors = State(
            initialValue: defaults.bool(forKey: "useCustomColors")
        )

        // Load custom colors
        if let textColorData = defaults.data(forKey: "overlayTextColor"),
           let textColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: textColorData)
        {
            _overlayTextColor = State(initialValue: Color(textColor))
        } else {
            _overlayTextColor = State(initialValue: Color.primary)
        }

        if let bgColorData = defaults.data(forKey: "overlayBackgroundColor"),
           let bgColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: bgColorData)
        {
            _overlayBackgroundColor = State(initialValue: Color(bgColor))
        } else {
            _overlayBackgroundColor = State(initialValue: Color.clear)
        }
    }

    var body: some View {
        ScrollView {
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

                Divider()
                    .padding(.vertical, 8)

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
                    title: "Use Custom Colors",
                    description: "Enable custom text and background colors for overlays.",
                    icon: "paintbrush"
                ) {
                    Toggle("", isOn: useCustomColorsBinding)
                        .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                        .scaleEffect(0.9, anchor: .trailing)
                }

                SettingItem(
                    title: "Text Color",
                    description: "Customize the text color in overlays.",
                    icon: "textformat"
                ) {
                    ColorPicker("", selection: overlayTextColorBinding, supportsOpacity: false)
                        .labelsHidden()
                }
                .opacity(useCustomColors ? 1.0 : 0.5)
                .disabled(!useCustomColors)

                SettingItem(
                    title: "Background Tint",
                    description: "Add a color tint to the overlay background.",
                    icon: "paintpalette"
                ) {
                    ColorPicker("", selection: overlayBackgroundColorBinding, supportsOpacity: true)
                        .labelsHidden()
                }
                .opacity(useCustomColors ? 1.0 : 0.5)
                .disabled(!useCustomColors)

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
                    description: "Test the overlay with current settings.",
                    icon: "eye"
                ) {
                    UIButton(
                        action: {
                            Notifier.shared.showOverlay(
                                title: "Overlay Preview",
                                message:
                                "This is how your overlays will look with the current settings.",
                                dismissAfter: 5.0,
                                isPreview: true
                            )
                        },
                        label: "Preview",
                        width: 120
                    )
                }

                Divider()
                    .padding(.vertical, 8)

                SettingItem(
                    title: "Disable During Presentations",
                    description: "Automatically pause reminders during screen sharing or presentations.",
                    icon: "rectangle.on.rectangle"
                ) {
                    Toggle("", isOn: disableDuringPresentationBinding)
                        .toggleStyle(.switch)
                }

                Divider()
                    .padding(.vertical, 8)

                SettingItem(
                    title: "Sound Effects",
                    description: "Play a sound when reminders appear.",
                    icon: "speaker.wave.2"
                ) {
                    Toggle("", isOn: soundEffectsEnabledBinding)
                        .toggleStyle(.switch)
                }

                if soundEffectsEnabled {
                    SettingItem(
                        title: "Sound",
                        description: "Choose a notification sound.",
                        icon: "music.note"
                    ) {
                        Picker("", selection: reminderSoundEffectBinding) {
                            ForEach(SoundManager.SoundEffect.allCases, id: \.rawValue) { sound in
                                Text(sound.displayName).tag(sound.rawValue)
                            }
                        }
                        .frame(width: 150)
                        .labelsHidden()
                    }

                    SettingItem(
                        title: "Volume",
                        description: "Adjust sound effect volume.",
                        icon: "speaker.wave.1"
                    ) {
                        HStack(spacing: 8) {
                            Slider(value: soundEffectsVolumeBinding, in: 0.0 ... 1.0, step: 0.1)
                                .frame(width: 150)

                            UIButton(
                                action: {
                                    if let sound = SoundManager.SoundEffect(rawValue: reminderSoundEffect) {
                                        SoundManager.shared.playSound(sound)
                                    }
                                },
                                label: "Test",
                                width: 60
                            )
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                InfoBox {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("The skip button is randomly placed to prevent developing muscle memory.")
                        Spacer()
                    }
                }

                InfoBox {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Text("Questions/bugs? Email me at enochlauenoch@gmail.com")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .padding()
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

    private var soundEffectsEnabledBinding: Binding<Bool> {
        Binding(
            get: { self.soundEffectsEnabled },
            set: {
                self.soundEffectsEnabled = $0
                UserDefaults.standard.set($0, forKey: "soundEffectsEnabled")
            }
        )
    }

    private var reminderSoundEffectBinding: Binding<String> {
        Binding(
            get: { self.reminderSoundEffect },
            set: {
                self.reminderSoundEffect = $0
                UserDefaults.standard.set($0, forKey: "reminderSoundEffect")
            }
        )
    }

    private var soundEffectsVolumeBinding: Binding<Double> {
        Binding(
            get: { self.soundEffectsVolume },
            set: {
                self.soundEffectsVolume = $0
                UserDefaults.standard.set($0, forKey: "soundEffectsVolume")
            }
        )
    }

    private var disableDuringPresentationBinding: Binding<Bool> {
        Binding(
            get: { self.disableDuringPresentation },
            set: {
                self.disableDuringPresentation = $0
                UserDefaults.standard.set($0, forKey: "disableDuringPresentation")
            }
        )
    }

    private var useCustomColorsBinding: Binding<Bool> {
        Binding(
            get: { self.useCustomColors },
            set: {
                self.useCustomColors = $0
                UserDefaults.standard.set($0, forKey: "useCustomColors")
            }
        )
    }

    private var overlayTextColorBinding: Binding<Color> {
        Binding(
            get: { self.overlayTextColor },
            set: {
                self.overlayTextColor = $0
                let nsColor = NSColor($0)
                if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false) {
                    UserDefaults.standard.set(colorData, forKey: "overlayTextColor")
                }
            }
        )
    }

    private var overlayBackgroundColorBinding: Binding<Color> {
        Binding(
            get: { self.overlayBackgroundColor },
            set: {
                self.overlayBackgroundColor = $0
                let nsColor = NSColor($0)
                if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false) {
                    UserDefaults.standard.set(colorData, forKey: "overlayBackgroundColor")
                }
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
