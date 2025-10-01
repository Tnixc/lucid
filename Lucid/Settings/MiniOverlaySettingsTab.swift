import Foundation
import SwiftUI

struct MiniOverlaySettingsTab: View {
    @State private var enabled: Bool
    @State private var text: String
    @State private var duration: Double
    @State private var holdDuration: Double
    @State private var interval: Int
    @State private var icon: String
    @State private var showingIconPicker: Bool = false
    @State private var backgroundColor: NSColor
    @State private var foregroundColor: NSColor
    @State private var useCustomColors: Bool
    @State private var verticalOffset: Int

    private let defaults = UserDefaults.standard

    // Common SF Symbol icons for wellness reminders
    private let iconOptions = [
        "sparkles",
        "star.fill",
        "heart.fill",
        "leaf.fill",
        "drop.fill",
        "figure.stand",
        "figure.walk",
        "eye.fill",
        "lungs.fill",
        "brain.head.profile",
        "cup.and.saucer.fill",
        "bell.fill",
        "lightbulb.fill",
        "sun.max.fill",
        "moon.fill",
    ]

    init() {
        let defaults = UserDefaults.standard

        _enabled = State(
            initialValue: defaults.object(forKey: "miniOverlayEnabled") as? Bool ?? false
        )

        _text = State(
            initialValue: defaults.string(forKey: "miniOverlayText") ?? "Posture check"
        )

        _duration = State(
            initialValue: defaults.object(forKey: "miniOverlayDuration") as? Double ?? 3.15
        )

        _holdDuration = State(
            initialValue: defaults.object(forKey: "miniOverlayHoldDuration") as? Double ?? 1.5
        )

        _interval = State(
            initialValue: defaults.integer(forKey: "miniOverlayInterval")
        )

        _icon = State(
            initialValue: defaults.string(forKey: "miniOverlayIcon") ?? "sparkles"
        )

        // Load custom colors
        let defaultBgColor = NSColor.systemBlue
        let defaultFgColor = NSColor.white

        if let bgColorData = defaults.data(forKey: "miniOverlayBackgroundColor"),
           let bgColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: bgColorData)
        {
            _backgroundColor = State(initialValue: bgColor)
        } else {
            _backgroundColor = State(initialValue: defaultBgColor)
        }

        if let fgColorData = defaults.data(forKey: "miniOverlayForegroundColor"),
           let fgColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: fgColorData)
        {
            _foregroundColor = State(initialValue: fgColor)
        } else {
            _foregroundColor = State(initialValue: defaultFgColor)
        }

        _useCustomColors = State(
            initialValue: defaults.bool(forKey: "miniOverlayUseCustomColors")
        )

        _verticalOffset = State(
            initialValue: defaults.integer(forKey: "miniOverlayVerticalOffset")
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Style.Layout.padding) {
            Text("Mini Overlay Reminders").font(.title).padding()

            SettingItem(
                title: "Enable Mini Overlays",
                description: "Show brief reminder messages at regular intervals.",
                icon: "sparkles"
            ) {
                Toggle("", isOn: enabledBinding)
                    .toggleStyle(.switch)
            }

            if enabled {
                SettingItem(
                    title: "Reminder Text",
                    description: "The message displayed in the mini overlay.",
                    icon: "text.bubble"
                ) {
                    UITextField(text: textBinding, width: 200)
                }

                SettingItem(
                    title: "Icon",
                    description: "Symbol displayed alongside the text.",
                    icon: icon
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .frame(width: 32, height: 32)
                            .foregroundColor(.accentColor)

                        UIButton(
                            action: { showingIconPicker.toggle() },
                            label: "Choose Icon",
                            width: 120
                        )
                    }
                }

                if showingIconPicker {
                    SettingItemGroup {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose an Icon")
                                .font(.headline)

                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: 44), spacing: 8),
                            ], spacing: 8) {
                                ForEach(iconOptions, id: \.self) { iconOption in
                                    Button(action: {
                                        icon = iconOption
                                        defaults.set(iconOption, forKey: "miniOverlayIcon")
                                        showingIconPicker = false
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(icon == iconOption ? Color.accentColor.opacity(0.2) : Color.clear)
                                                .frame(width: 44, height: 44)

                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    icon == iconOption ? Color.accentColor : Color.secondary.opacity(0.3),
                                                    lineWidth: icon == iconOption ? 2 : 1
                                                )
                                                .frame(width: 44, height: 44)

                                            Image(systemName: iconOption)
                                                .font(.system(size: 20))
                                                .foregroundColor(icon == iconOption ? .accentColor : .primary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }

                SettingItem(
                    title: "Animation Duration (seconds)",
                    description: "How long the entire animation takes to complete.",
                    icon: "timer"
                ) {
                    HStack(spacing: 8) {
                        Slider(
                            value: durationBinding,
                            in: 2.0 ... 6.0,
                            step: 0.5
                        )
                        .frame(width: 120)

                        Text(String(format: "%.1fs", duration))
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 45, alignment: .trailing)
                    }
                }

                SettingItem(
                    title: "Display Duration (seconds)",
                    description: "How long the message stays visible in full.",
                    icon: "hourglass"
                ) {
                    HStack(spacing: 8) {
                        Slider(
                            value: holdDurationBinding,
                            in: 1.0 ... 30.0,
                            step: 1
                        )
                        .frame(width: 240)

                        Text(String(format: "%.1fs", holdDuration))
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 45, alignment: .trailing)
                    }
                }

                SettingItem(
                    title: "Frequency (minutes)",
                    description: "Time between mini overlay reminders.",
                    icon: "clock"
                ) {
                    UINumberField(value: intervalBinding, width: 60)
                }

                SettingItem(
                    title: "Use Custom Colors",
                    description: "Override the system accent color with custom colors.",
                    icon: "paintpalette"
                ) {
                    Toggle("", isOn: useCustomColorsBinding)
                        .toggleStyle(.switch)
                }

                if useCustomColors {
                    SettingItem(
                        title: "Background Color",
                        description: "Color of the mini overlay background.",
                        icon: "circle.fill"
                    ) {
                        ColorPicker("", selection: backgroundColorBinding, supportsOpacity: false)
                            .labelsHidden()
                    }

                    SettingItem(
                        title: "Foreground Color",
                        description: "Color of the text and icon.",
                        icon: "textformat"
                    ) {
                        ColorPicker("", selection: foregroundColorBinding, supportsOpacity: false)
                            .labelsHidden()
                    }
                }

                SettingItem(
                    title: "Vertical Offset (pixels)",
                    description: "Distance from the bottom of the screen.",
                    icon: "arrow.up.and.down"
                ) {
                    UINumberField(value: verticalOffsetBinding, width: 60)
                }

                SettingItem(
                    title: "Preview",
                    description: "Show a preview of the mini overlay reminder.",
                    icon: "eye"
                ) {
                    UIButton(
                        action: {
                            let bgColor = useCustomColors ? Color(backgroundColor) : nil
                            let fgColor = useCustomColors ? Color(foregroundColor) : nil
                            Notifier.shared.showMiniOverlay(
                                text: text,
                                icon: icon,
                                duration: duration,
                                holdDuration: holdDuration,
                                backgroundColor: bgColor,
                                foregroundColor: fgColor,
                                verticalOffset: CGFloat(verticalOffset),
                                isPreview: true
                            )
                        },
                        label: "Preview",
                        width: 120
                    )
                }

                // Preset suggestions
                SettingItemGroup {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.accentColor)
                            Text("Preset Messages")
                                .font(.headline)
                        }

                        Text("Quick suggestions for common wellness reminders:")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ], spacing: 8) {
                            PresetButton(title: "Posture check", icon: "figure.stand") {
                                text = "Posture check"
                                icon = "figure.stand"
                                defaults.set("Posture check", forKey: "miniOverlayText")
                                defaults.set("figure.stand", forKey: "miniOverlayIcon")
                            }

                            PresetButton(title: "Stay hydrated", icon: "drop.fill") {
                                text = "Stay hydrated"
                                icon = "drop.fill"
                                defaults.set("Stay hydrated", forKey: "miniOverlayText")
                                defaults.set("drop.fill", forKey: "miniOverlayIcon")
                            }

                            PresetButton(title: "Blink more", icon: "eye.fill") {
                                text = "Blink more"
                                icon = "eye.fill"
                                defaults.set("Blink more", forKey: "miniOverlayText")
                                defaults.set("eye.fill", forKey: "miniOverlayIcon")
                            }

                            PresetButton(title: "Stretch time", icon: "figure.walk") {
                                text = "Stretch time"
                                icon = "figure.walk"
                                defaults.set("Stretch time", forKey: "miniOverlayText")
                                defaults.set("figure.walk", forKey: "miniOverlayIcon")
                            }

                            PresetButton(title: "Deep breath", icon: "lungs.fill") {
                                text = "Deep breath"
                                icon = "lungs.fill"
                                defaults.set("Deep breath", forKey: "miniOverlayText")
                                defaults.set("lungs.fill", forKey: "miniOverlayIcon")
                            }

                            PresetButton(title: "Look away", icon: "sparkles") {
                                text = "Look away"
                                icon = "sparkles"
                                defaults.set("Look away", forKey: "miniOverlayText")
                                defaults.set("sparkles", forKey: "miniOverlayIcon")
                            }
                        }
                    }
                }
            }

            Spacer()
        }
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { self.enabled },
            set: {
                self.enabled = $0
                defaults.set($0, forKey: "miniOverlayEnabled")
                if $0 {
                    Notifier.shared.updateSettings()
                }
            }
        )
    }

    private var textBinding: Binding<String> {
        Binding(
            get: { self.text },
            set: {
                self.text = $0
                defaults.set($0, forKey: "miniOverlayText")
            }
        )
    }

    private var durationBinding: Binding<Double> {
        Binding(
            get: { self.duration },
            set: {
                self.duration = $0
                defaults.set($0, forKey: "miniOverlayDuration")
            }
        )
    }

    private var holdDurationBinding: Binding<Double> {
        Binding(
            get: { self.holdDuration },
            set: {
                self.holdDuration = $0
                defaults.set($0, forKey: "miniOverlayHoldDuration")
            }
        )
    }

    private var intervalBinding: Binding<Int> {
        Binding(
            get: { self.interval },
            set: {
                self.interval = $0
                defaults.set($0, forKey: "miniOverlayInterval")
                Notifier.shared.updateSettings()
            }
        )
    }

    private var useCustomColorsBinding: Binding<Bool> {
        Binding(
            get: { self.useCustomColors },
            set: {
                self.useCustomColors = $0
                defaults.set($0, forKey: "miniOverlayUseCustomColors")
            }
        )
    }

    private var backgroundColorBinding: Binding<Color> {
        Binding(
            get: { Color(self.backgroundColor) },
            set: { newValue in
                let nsColor = NSColor(newValue)
                self.backgroundColor = nsColor
                if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false) {
                    defaults.set(colorData, forKey: "miniOverlayBackgroundColor")
                }
            }
        )
    }

    private var foregroundColorBinding: Binding<Color> {
        Binding(
            get: { Color(self.foregroundColor) },
            set: { newValue in
                let nsColor = NSColor(newValue)
                self.foregroundColor = nsColor
                if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false) {
                    defaults.set(colorData, forKey: "miniOverlayForegroundColor")
                }
            }
        )
    }

    private var verticalOffsetBinding: Binding<Int> {
        Binding(
            get: { self.verticalOffset },
            set: {
                self.verticalOffset = $0
                defaults.set($0, forKey: "miniOverlayVerticalOffset")
            }
        )
    }
}

struct PresetButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 13))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
