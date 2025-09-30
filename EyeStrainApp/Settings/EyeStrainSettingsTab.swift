import SwiftUI

struct EyeStrainSettingsTab: View {
    @State private var interval: Int
    @State private var title: String
    @State private var message: String
    @State private var dismissAfter: Int

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
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Style.Layout.padding) {
            Text("Eye Strain Reminders").font(.title).padding()

            SettingItem(
                title: "Interval (minutes)",
                description: "Time between eye strain reminders.",
                icon: "timer"
            ) {
                TextField("", value: intervalBinding, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
            }

            SettingItem(
                title: "Reminder Title",
                description: "Title displayed on the reminder overlay.",
                icon: "text.bubble"
            ) {
                TextField("", text: titleBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            SettingItem(
                title: "Reminder Message",
                description: "Message displayed on the reminder overlay.",
                icon: "text.quote"
            ) {
                TextField("", text: messageBinding)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            SettingItem(
                title: "Dismiss After (seconds)",
                description: "Time before the overlay auto-dismisses.",
                icon: "clock"
            ) {
                TextField("", value: dismissAfterBinding, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
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
}
