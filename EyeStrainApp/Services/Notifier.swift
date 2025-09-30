import Foundation
import SwiftUI
import UserNotifications

class Notifier {
    static let shared = Notifier()

    private var lastClockOutCheck: Date?
    private var clockOutTime: Date?
    private var lastReminderTime: Date?
    private var bedtimeTime: Date?
    private var lastBedtimeCheck: Date?
    private let defaults = UserDefaults.standard
    private var activeDays: Set<Int> = []
    private var clockOutUseOverlay: Bool?
    var overlayWindow: NSWindow?

    func showOverlay(title: String, message: String, dismissAfter: TimeInterval) {
        overlayWindow = generateOverlay(
            title: title,
            message: message,
            seconds: dismissAfter,
            onDismiss: {
                [weak self] in
                self?.overlayWindow?.close()
                self?.overlayWindow = nil
            }
        )

        overlayWindow?.makeKeyAndOrderFront(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissAfter) {
            [weak self] in
            self?.overlayWindow?.close()
            self?.overlayWindow = nil
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
        showOverlay(title: title, message: message, dismissAfter: dismissAfter)
    }

    private init() {
        updateSettings()
        requestNotificationPermission()
    }

    func updateSettings() {
        clockOutTime = defaults.object(forKey: "clockOutTime") as? Date
        activeDays = Set(
            defaults.array(forKey: "clockOutSelectedDays") as? [Int] ?? []
        )
        clockOutUseOverlay = defaults.object(forKey: "clockOutUseOverlay") as? Bool
        bedtimeTime = defaults.object(forKey: "bedtimeTime") as? Date
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
        guard defaults.bool(forKey: "bedtimeEnabled"),
              let bedtimeTime = bedtimeTime
        else {
            return
        }

        let now = Date()
        let calendar = Calendar.current

        let bedtimeComponents = calendar.dateComponents(
            [.hour, .minute],
            from: bedtimeTime
        )
        let currentComponents = calendar.dateComponents(
            [.hour, .minute],
            from: now
        )

        if bedtimeComponents == currentComponents {
            if lastBedtimeCheck == nil
                || !calendar.isDate(lastBedtimeCheck!, inSameDayAs: now)
            {
                showBedtimeReminder()
                lastBedtimeCheck = now
            }
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
