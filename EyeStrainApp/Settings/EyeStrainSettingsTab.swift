import Foundation
import SwiftUI

struct EyeStrainSettingsTab: View {
    @State private var interval: Int
    @State private var title: String
    @State private var message: String
    @State private var dismissAfter: Int
    @State private var clickToDismiss: Bool

    init() {
        let defaults = UserDefaults.standard
        _interval = State(
            initialValue: defaults.integer(forKey: "eyeStrainInterval")
        )
        if _interval.wrappedValue == 0 { _interval.wrappedValue = 20 }
        _title = State(
            initialValue: defaults.string(forKey: "eyeStrainTitle")
                ?? "Eye Strain Break"
        )
        _message = State(
            initialValue: defaults.string(forKey: "eyeStrainMessage")
                ?? "Look away from the screen and rest your eyes."
        )
        _dismissAfter = State(
            initialValue: defaults.integer(forKey: "eyeStrainDismissAfter")
        )
        if _dismissAfter.wrappedValue == 0 { _dismissAfter.wrappedValue = 20 }
        _clickToDismiss = State(
            initialValue: defaults.object(forKey: "eyeStrainClickToDismiss") as? Bool ?? true
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Style.Layout.padding) {
            Text("Eye Strain Reminders").font(.title).padding()

            SettingItem(
                title: "Interval (minutes)",
                description: "Time between eye strain reminders.",
                icon: "timer"
            ) {
                UINumberField(value: intervalBinding, width: 60)
            }

            SettingItem(
                title: "Reminder Title",
                description: "Title displayed on the reminder overlay.",
                icon: "text.bubble"
            ) {
                UITextField(text: titleBinding)
            }

            SettingItem(
                title: "Reminder Message",
                description: "Message displayed on the reminder overlay.",
                icon: "text.quote"
            ) {
                UITextField(text: messageBinding)
            }

            SettingItem(
                title: "Dismiss After (seconds)",
                description: "Time before the overlay auto-dismisses.",
                icon: "clock"
            ) {
                UINumberField(value: dismissAfterBinding, width: 60)
            }

            SettingItem(
                title: "Click to Dismiss",
                description: "Allow clicking on the overlay to dismiss it.",
                icon: "hand.tap"
            ) {
                Toggle("", isOn: clickToDismissBinding)
                    .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                    .scaleEffect(0.9, anchor: .trailing)
            }

            SettingItem(
                title: "Preview",
                description: "Show a preview of the eye strain reminder overlay.",
                icon: "eye"
            ) {
                UIButton(action: { Notifier.shared.showEyeStrainReminder() }, label: "Preview", width: 120)
            }

            Spacer()
        }
    }

    private var intervalBinding: Binding<Int> {
        Binding(
            get: { self.interval },
            set: {
                self.interval = $0
                UserDefaults.standard.set($0, forKey: "eyeStrainInterval")
            }
        )
    }

    private var titleBinding: Binding<String> {
        Binding(
            get: { self.title },
            set: {
                self.title = $0
                UserDefaults.standard.set($0, forKey: "eyeStrainTitle")
            }
        )
    }

    private var messageBinding: Binding<String> {
        Binding(
            get: { self.message },
            set: {
                self.message = $0
                UserDefaults.standard.set($0, forKey: "eyeStrainMessage")
            }
        )
    }

    private var dismissAfterBinding: Binding<Int> {
        Binding(
            get: { self.dismissAfter },
            set: {
                self.dismissAfter = $0
                UserDefaults.standard.set($0, forKey: "eyeStrainDismissAfter")
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
}
