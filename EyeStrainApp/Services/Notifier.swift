import Foundation
import KeyboardShortcuts
import SwiftUI
import UserNotifications

class Notifier {
    static let shared = Notifier()

    private var lastClockOutCheck: Date?
    private var clockOutTime: Date?
    private var lastReminderTime: Date?
    private var bedtimeStartTime: Date?
    private var bedtimeEndTime: Date?
    private var lastBedtimeCheck: Date?
    private var lastBedtimeReminderTime: Date?
    private let defaults = UserDefaults.standard
    private var activeDays: Set<Int> = []
    private var clockOutUseOverlay: Bool?
    var overlayWindows: [NSWindow] = []

    private init() {
        updateSettings()
        setupKeyboardShortcuts()
        requestNotificationPermission()
    }

    func showOverlay(title: String, message: String, dismissAfter: TimeInterval, autoDismiss: Bool = true) {
        // Close any existing overlay windows
        overlayWindows.forEach { $0.close() }
        overlayWindows.removeAll()

        // Create an overlay window for each screen
        let screens = NSScreen.screens
        for screen in screens {
            let window = generateOverlay(
                title: title,
                message: message,
                seconds: dismissAfter,
                screen: screen,
                onDismiss: {
                    [weak self] in
                    self?.overlayWindows.forEach { $0.close() }
                    self?.overlayWindows.removeAll()
                }
            )

            window.makeKeyAndOrderFront(nil)
            overlayWindows.append(window)
        }

        if autoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + dismissAfter) {
                [weak self] in
                self?.overlayWindows.forEach { $0.close() }
                self?.overlayWindows.removeAll()
            }
        }
    }

    func showEyeStrainReminder() {
        let title = defaults.string(forKey: "eyeStrainTitle") ?? "Eye Strain Break"
        let message =
            defaults.string(forKey: "eyeStrainMessage")
                ?? "Look away from the screen and rest your eyes."
        var dismissAfter = TimeInterval(
            defaults.integer(forKey: "eyeStrainDismissAfter")
        )
        if dismissAfter == 0 { dismissAfter = 20 } // default 20 seconds
        showOverlay(title: title, message: message, dismissAfter: dismissAfter)
    }

    func showBedtimeReminder() {
        let title = defaults.string(forKey: "bedtimeTitle") ?? "Bedtime Reminder"
        let message =
            defaults.string(forKey: "bedtimeMessage")
                ?? "It's time to go to bed and get some rest."
        var dismissAfter = TimeInterval(
            defaults.integer(forKey: "bedtimeDismissAfter")
        )
        if dismissAfter == 0 { dismissAfter = 30 } // default 30 seconds
        let autoDismiss = defaults.object(forKey: "bedtimeAutoDismiss") as? Bool ?? true
        showOverlay(title: title, message: message, dismissAfter: dismissAfter, autoDismiss: autoDismiss)
    }

    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyDown(for: .dismissOverlay) { [weak self] in
            guard let self = self else { return }
            self.overlayWindows.forEach { $0.close() }
            self.overlayWindows.removeAll()
        }
    }

    func updateSettings() {
        clockOutTime = defaults.object(forKey: "clockOutTime") as? Date
        activeDays = Set(
            defaults.array(forKey: "clockOutSelectedDays") as? [Int] ?? []
        )
        clockOutUseOverlay = defaults.object(forKey: "clockOutUseOverlay") as? Bool
        bedtimeStartTime = defaults.object(forKey: "bedtimeStartTime") as? Date
        bedtimeEndTime = defaults.object(forKey: "bedtimeEndTime") as? Date
    }

    func checkClockOutTime() {
        guard defaults.bool(forKey: "clockOutEnabled"),
              let clockOutTime = clockOutTime
        else {
            return
        }

        let now = Date()
        let calendar = Calendar.current

        // Check if today is an active day
        let today = calendar.component(.weekday, from: now)
        guard activeDays.contains(today) else {
            return
        }

        let clockOutComponents = calendar.dateComponents(
            [.hour, .minute],
            from: clockOutTime
        )
        let currentComponents = calendar.dateComponents(
            [.hour, .minute],
            from: now
        )

        if clockOutComponents == currentComponents {
            if lastClockOutCheck == nil
                || !calendar.isDate(lastClockOutCheck!, inSameDayAs: now)
            {
                clockOutMain()
                lastClockOutCheck = now
                lastReminderTime = now
            }
        } else if let lastReminder = lastReminderTime,
                  defaults.bool(forKey: "clockOutReminderEnabled")
        {
            let reminderInterval = TimeInterval(
                defaults.integer(forKey: "clockOutReminderInterval") * 60
            )
            if now.timeIntervalSince(lastReminder) >= reminderInterval {
                clockOutReminder()
                lastReminderTime = now
            }
        }
    }

    func checkBedtimeTime() {
        // Skip if settings window is open
        guard !AppState.shared.isSettingsWindowOpen else {
            return
        }

        guard defaults.bool(forKey: "bedtimeEnabled"),
              let bedtimeStartTime = bedtimeStartTime,
              let bedtimeEndTime = bedtimeEndTime
        else {
            return
        }

        let now = Date()
        let calendar = Calendar.current

        let startComponents = calendar.dateComponents([.hour, .minute], from: bedtimeStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: bedtimeEndTime)
        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)

        guard let startHour = startComponents.hour,
              let startMinute = startComponents.minute,
              let endHour = endComponents.hour,
              let endMinute = endComponents.minute,
              let currentHour = currentComponents.hour,
              let currentMinute = currentComponents.minute
        else {
            return
        }

        // Convert to minutes since midnight for easier comparison
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let currentMinutes = currentHour * 60 + currentMinute

        // Check if current time is within bedtime range
        let currentlyInBedtime: Bool
        if endMinutes < startMinutes {
            // Range spans midnight (e.g., 22:00 to 6:00)
            currentlyInBedtime = currentMinutes >= startMinutes || currentMinutes <= endMinutes
        } else {
            // Range within same day (e.g., 10:00 to 18:00)
            currentlyInBedtime = currentMinutes >= startMinutes && currentMinutes <= endMinutes
        }

        if currentlyInBedtime {
            let repeatReminders = defaults.bool(forKey: "bedtimeRepeatReminders")

            if repeatReminders {
                // Show reminder repeatedly at intervals
                if lastBedtimeReminderTime == nil {
                    // First reminder when entering bedtime
                    showBedtimeReminder()
                    lastBedtimeReminderTime = now
                } else {
                    // Check if enough time has passed for a repeat reminder
                    let repeatInterval = TimeInterval(defaults.integer(forKey: "bedtimeRepeatInterval") * 60)
                    let interval = repeatInterval > 0 ? repeatInterval : 15 * 60 // default 15 minutes
                    if now.timeIntervalSince(lastBedtimeReminderTime!) >= interval {
                        showBedtimeReminder()
                        lastBedtimeReminderTime = now
                    }
                }
                lastBedtimeCheck = now
            } else {
                // Show reminder once per entry into bedtime range
                if lastBedtimeCheck == nil || !isInBedtimeRange(lastBedtimeCheck!) {
                    showBedtimeReminder()
                    lastBedtimeCheck = now
                    lastBedtimeReminderTime = now
                }
            }
        } else {
            // Reset reminder time when leaving bedtime range
            lastBedtimeReminderTime = nil
        }
    }

    private func isInBedtimeRange(_ date: Date) -> Bool {
        guard let bedtimeStartTime = bedtimeStartTime,
              let bedtimeEndTime = bedtimeEndTime
        else {
            return false
        }

        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: bedtimeStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: bedtimeEndTime)
        let checkComponents = calendar.dateComponents([.hour, .minute], from: date)

        guard let startHour = startComponents.hour,
              let startMinute = startComponents.minute,
              let endHour = endComponents.hour,
              let endMinute = endComponents.minute,
              let checkHour = checkComponents.hour,
              let checkMinute = checkComponents.minute
        else {
            return false
        }

        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        let checkMinutes = checkHour * 60 + checkMinute

        if endMinutes < startMinutes {
            return checkMinutes >= startMinutes || checkMinutes <= endMinutes
        } else {
            return checkMinutes >= startMinutes && checkMinutes <= endMinutes
        }
    }

    private func clockOutMain() {
        if clockOutUseOverlay ?? false {
            let date = Date()
            let midTime = DateFormatter.localizedString(
                from: date,
                dateStyle: .none,
                timeStyle: .short
            )
            showOverlay(
                title: "Time to clock out",
                message: "The time is \(midTime)",
                dismissAfter: 5.0
            )
        } else {
            sendNotification(title: "Clock Out", body: "It's time to clock out!")
        }
    }

    private func clockOutReminder() {
        sendNotification(
            title: "Clock Out Reminder",
            body: "Don't forget to clock out!"
        )
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .sound, .badge,
        ]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print(
                    "Error requesting notification permission: \(error.localizedDescription)"
                )
            }
        }
    }
}

extension KeyboardShortcuts.Name {
    static let dismissOverlay = Self("dismissOverlay")
}
