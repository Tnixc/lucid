import Foundation
import SwiftUI

struct BedtimeSettingsTab: View {
    @State private var enabled: Bool
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var endHour: Int
    @State private var endMinute: Int
    @State private var title: String
    @State private var message: String
    @State private var dismissAfter: Int
    @State private var repeatReminders: Bool
    @State private var repeatInterval: Int
    @State private var autoDismiss: Bool

    init() {
        let defaults = UserDefaults.standard
        _enabled = State(initialValue: defaults.bool(forKey: "bedtimeEnabled"))

        // Load start time (default 22:00 / 10 PM)
        let startTime =
            defaults.object(forKey: "bedtimeStartTime") as? Date ?? Calendar
                .current.date(from: DateComponents(hour: 22, minute: 0))!
        let startComponents = Calendar.current.dateComponents(
            [.hour, .minute],
            from: startTime
        )
        _startHour = State(initialValue: startComponents.hour ?? 22)
        _startMinute = State(initialValue: startComponents.minute ?? 0)

        // Load end time (default 6:00 / 6 AM)
        let endTime =
            defaults.object(forKey: "bedtimeEndTime") as? Date ?? Calendar
                .current.date(from: DateComponents(hour: 6, minute: 0))!
        let endComponents = Calendar.current.dateComponents(
            [.hour, .minute],
            from: endTime
        )
        _endHour = State(initialValue: endComponents.hour ?? 6)
        _endMinute = State(initialValue: endComponents.minute ?? 0)

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

        _repeatReminders = State(
            initialValue: defaults.bool(forKey: "bedtimeRepeatReminders")
        )
        _repeatInterval = State(
            initialValue: defaults.integer(forKey: "bedtimeRepeatInterval")
        )
        if _repeatInterval.wrappedValue == 0 { _repeatInterval.wrappedValue = 15 }

        _autoDismiss = State(
            initialValue: defaults.object(forKey: "bedtimeAutoDismiss") as? Bool ?? true
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Style.Layout.padding) {
            Text("Bedtime Reminders").font(.title).padding()

            SettingItem(
                title: "Enable Bedtime Reminders",
                description: "Show reminders during bedtime hours.",
                icon: "moon"
            ) {
                Toggle("", isOn: enabledBinding)
                    .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                    .scaleEffect(0.9, anchor: .trailing)
            }

            VStack(alignment: .leading, spacing: Style.Layout.padding) {
                HStack {
                    Image(systemName: "clock")
                        .renderingMode(.template)
                        .font(.title3)
                        .frame(width: Style.Icon.size, height: Style.Icon.size)
                    VStack(alignment: .leading) {
                        Text("Bedtime Hours")
                        Text("Set when you want bedtime reminders to be active.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer().frame(height: 10.0)

                TimelineEditor(
                    startHour: startHourBinding,
                    startMinute: startMinuteBinding,
                    endHour: endHourBinding,
                    endMinute: endMinuteBinding
                )
            }
            .padding(Style.Layout.padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Style.Layout.cornerRadius + 2)
                        .fill(Style.Settings.itembg)
                    RoundedRectangle(cornerRadius: Style.Layout.cornerRadius + 2)
                        .stroke(
                            Style.Settings.itemBorder,
                            lineWidth: Style.Layout.borderWidth
                        )
                }
            )

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
                title: "Auto-dismiss Overlay",
                description: "Automatically dismiss the overlay after a set time.",
                icon: "xmark.circle"
            ) {
                Toggle("", isOn: autoDismissBinding)
                    .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                    .scaleEffect(0.9, anchor: .trailing)
            }

            SettingItem(
                title: "Dismiss After (seconds)",
                description: "Time before the overlay auto-dismisses.",
                icon: "clock"
            ) {
                UINumberField(value: dismissAfterBinding, width: 60)
            }
            .opacity(autoDismiss ? 1.0 : 0.5)
            .disabled(!autoDismiss)

            SettingItem(
                title: "Repeat Reminders",
                description: "Show reminders repeatedly during bedtime hours.",
                icon: "repeat"
            ) {
                Toggle("", isOn: repeatRemindersBinding)
                    .toggleStyle(SwitchToggleStyle(tint: Style.Colors.accent))
                    .scaleEffect(0.9, anchor: .trailing)
            }

            SettingItem(
                title: "Repeat Interval (minutes)",
                description: "Time between repeated reminders.",
                icon: "timer"
            ) {
                UINumberField(value: repeatIntervalBinding, width: 60)
            }
            .opacity(repeatReminders ? 1.0 : 0.5)
            .disabled(!repeatReminders)

            SettingItem(
                title: "Preview",
                description: "Show a preview of the bedtime reminder overlay.",
                icon: "moon"
            ) {
                UIButton(
                    action: { Notifier.shared.showBedtimeReminder() },
                    label: "Preview",
                    width: 120
                )
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

    private var startHourBinding: Binding<Int> {
        Binding(
            get: { self.startHour },
            set: {
                self.startHour = $0
                let date = Calendar.current.date(
                    from: DateComponents(hour: $0, minute: startMinute)
                )!
                UserDefaults.standard.set(date, forKey: "bedtimeStartTime")
                Notifier.shared.updateSettings()
            }
        )
    }

    private var startMinuteBinding: Binding<Int> {
        Binding(
            get: { self.startMinute },
            set: {
                self.startMinute = $0
                let date = Calendar.current.date(
                    from: DateComponents(hour: startHour, minute: $0)
                )!
                UserDefaults.standard.set(date, forKey: "bedtimeStartTime")
                Notifier.shared.updateSettings()
            }
        )
    }

    private var endHourBinding: Binding<Int> {
        Binding(
            get: { self.endHour },
            set: {
                self.endHour = $0
                let date = Calendar.current.date(
                    from: DateComponents(hour: $0, minute: endMinute)
                )!
                UserDefaults.standard.set(date, forKey: "bedtimeEndTime")
                Notifier.shared.updateSettings()
            }
        )
    }

    private var endMinuteBinding: Binding<Int> {
        Binding(
            get: { self.endMinute },
            set: {
                self.endMinute = $0
                let date = Calendar.current.date(
                    from: DateComponents(hour: endHour, minute: $0)
                )!
                UserDefaults.standard.set(date, forKey: "bedtimeEndTime")
                Notifier.shared.updateSettings()
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

    private var repeatRemindersBinding: Binding<Bool> {
        Binding(
            get: { self.repeatReminders },
            set: {
                self.repeatReminders = $0
                UserDefaults.standard.set($0, forKey: "bedtimeRepeatReminders")
                Notifier.shared.updateSettings()
            }
        )
    }

    private var repeatIntervalBinding: Binding<Int> {
        Binding(
            get: { self.repeatInterval },
            set: {
                self.repeatInterval = $0
                UserDefaults.standard.set($0, forKey: "bedtimeRepeatInterval")
                Notifier.shared.updateSettings()
            }
        )
    }

    private var autoDismissBinding: Binding<Bool> {
        Binding(
            get: { self.autoDismiss },
            set: {
                self.autoDismiss = $0
                UserDefaults.standard.set($0, forKey: "bedtimeAutoDismiss")
            }
        )
    }
}
