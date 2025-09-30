import Foundation
import KeyboardShortcuts
import SwiftUI

struct BedtimeSettingsTab: View {
    @State private var enabled: Bool
    @State private var bedtimeTime: Date
    @State private var title: String
    @State private var message: String
    @State private var dismissAfter: Int

    init() {
        let defaults = UserDefaults.standard
        _enabled = State(initialValue: defaults.bool(forKey: "bedtimeEnabled"))
        _bedtimeTime = State(
            initialValue: defaults.object(forKey: "bedtimeTime") as? Date ?? Calendar
                .current.date(from: DateComponents(hour: 22, minute: 0))!
        )
        _title = State(
            initialValue: defaults.string(forKey: "bedtimeTitle")
                ?? "Bedtime Reminder"
        )
        _message = State(
            initialValue: defaults.string(forKey: "bedtimeMessage")
                ?? "It's time to go to bed and get some rest."
        )
        _dismissAfter = State(
            initialValue: defaults.integer(forKey: "bedtimeDismissAfter")
        )
        if _dismissAfter.wrappedValue == 0 { _dismissAfter.wrappedValue = 30 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Style.Layout.padding) {
            Text("Bedtime Reminders").font(.title).padding()

            SettingItem(
                title: "Enable Bedtime Reminders",
                description: "Show reminders at bedtime.",
                icon: "moon"
            ) {
                Toggle("", isOn: enabledBinding)
                    .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                    .scaleEffect(0.9, anchor: .trailing)
            }

            SettingItem(
                title: "Bedtime",
                description: "Time to show bedtime reminder.",
                icon: "clock"
            ) {
                DatePicker(
                    "",
                    selection: bedtimeTimeBinding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
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

            SettingItem(
                title: "Dismiss Hotkey",
                description: "Shortcut to press to dismiss the overlay.",
                icon: "keyboard"
            ) {
                KeyboardShortcuts.Recorder(for: .dismissBedtime)
            }

            SettingItem(
                title: "Preview",
                description: "Show a preview of the bedtime reminder overlay.",
                icon: "moon"
            ) {
                UIButton(action: { Notifier.shared.showBedtimeReminder() }, label: "Preview")
            }

            Spacer()
        }
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { self.enabled },
            set: {
                self.enabled = $0
                UserDefaults.standard.set($0, forKey: "bedtimeEnabled")
            }
        )
    }

    private var bedtimeTimeBinding: Binding<Date> {
        Binding(
            get: { self.bedtimeTime },
            set: {
                self.bedtimeTime = $0
                UserDefaults.standard.set($0, forKey: "bedtimeTime")
            }
        )
    }

    private var titleBinding: Binding<String> {
        Binding(
            get: { self.title },
            set: {
                self.title = $0
                UserDefaults.standard.set($0, forKey: "bedtimeTitle")
            }
        )
    }

    private var messageBinding: Binding<String> {
        Binding(
            get: { self.message },
            set: {
                self.message = $0
                UserDefaults.standard.set($0, forKey: "bedtimeMessage")
            }
        )
    }

    private var dismissAfterBinding: Binding<Int> {
        Binding(
            get: { self.dismissAfter },
            set: {
                self.dismissAfter = $0
                UserDefaults.standard.set($0, forKey: "bedtimeDismissAfter")
            }
        )
    }
}
