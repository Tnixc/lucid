import AVFoundation
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
    private var lastMiniOverlayTime: Date?
    private let defaults = UserDefaults.standard
    private var activeDays: Set<Int> = []
    private var clockOutUseOverlay: Bool?
    var overlayWindows: [NSWindow] = []
    var miniOverlayWindows: [NSWindow] = []
    private var persistentBedtimeTimer: Timer?

    private init() {
        updateSettings()
        setupKeyboardShortcuts()
        setupPersistentBedtimeTimer()
    }

    func showOverlay(title: String, message: String, dismissAfter: TimeInterval, autoDismiss: Bool = true, isPreview: Bool = false) {
        // Skip if settings window is open (unless this is a preview)
        guard isPreview || !AppState.shared.isSettingsWindowOpen else {
            return
        }

        // Skip if presentation mode is active (unless this is a preview)
        guard isPreview || !PresentationModeDetector.shared.isPresentationModeActive else {
            return
        }

        // Check if alerts are enabled (skip check for previews)
        guard isPreview || defaults.bool(forKey: "alertsEnabled") != false else {
            return
        }

        // Play sound if enabled
        if !isPreview {
            SoundManager.shared.playReminderSound()
        }

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
                autoDismiss: autoDismiss,
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

    func showMiniOverlay(text: String, icon: String? = nil, duration: TimeInterval = 3.15, holdDuration: TimeInterval = 1.5, backgroundColor: Color? = nil, foregroundColor: Color? = nil, verticalOffset: CGFloat = 60, isPreview: Bool = false) {
        // Skip if settings window is open (unless this is a preview)
        guard isPreview || !AppState.shared.isSettingsWindowOpen else {
            return
        }

        // Skip if presentation mode is active (unless this is a preview)
        guard isPreview || !PresentationModeDetector.shared.isPresentationModeActive else {
            return
        }

        // Check if alerts are enabled (skip check for previews)
        guard isPreview || defaults.bool(forKey: "alertsEnabled") != false else {
            return
        }

        // Play sound if enabled
        if !isPreview {
            SoundManager.shared.playReminderSound()
        }

        // Close any existing mini overlay windows
        miniOverlayWindows.forEach { $0.close() }
        miniOverlayWindows.removeAll()

        // Create a mini overlay window for each screen
        let screens = NSScreen.screens
        for screen in screens {
            let window = generateMiniOverlay(
                text: text,
                icon: icon,
                screen: screen,
                duration: duration,
                holdDuration: holdDuration,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                verticalOffset: verticalOffset,
                onDismiss: {
                    [weak self] in
                    self?.miniOverlayWindows.forEach { $0.close() }
                    self?.miniOverlayWindows.removeAll()
                }
            )

            window.makeKeyAndOrderFront(nil)
            miniOverlayWindows.append(window)
        }
    }

    func showEyeStrainReminder(isPreview: Bool = false) {
        let title = defaults.string(forKey: "eyeStrainTitle") ?? "Eye Strain Break"
        let message =
            defaults.string(forKey: "eyeStrainMessage")
                ?? "Look away from the screen and rest your eyes."
        let dismissAfter = TimeInterval(
            defaults.integer(forKey: "eyeStrainDismissAfter")
        )
        showOverlay(title: title, message: message, dismissAfter: dismissAfter, isPreview: isPreview)
    }

    func showBedtimeReminder(isPreview: Bool = false) {
        let title = defaults.string(forKey: "bedtimeTitle") ?? "Bedtime Reminder"
        let message =
            defaults.string(forKey: "bedtimeMessage")
                ?? "It's time to go to bed and get some rest."
        let dismissAfter = TimeInterval(
            defaults.integer(forKey: "bedtimeDismissAfter")
        )
        let autoDismiss = defaults.object(forKey: "bedtimeAutoDismiss") as? Bool ?? true
        showOverlay(title: title, message: message, dismissAfter: dismissAfter, autoDismiss: autoDismiss, isPreview: isPreview)
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
        setupPersistentBedtimeTimer()
    }

    private func setupPersistentBedtimeTimer() {
        // Invalidate existing timer
        persistentBedtimeTimer?.invalidate()
        persistentBedtimeTimer = nil

        // Only create timer if persistent mode is enabled
        guard defaults.bool(forKey: "bedtimePersistent"),
              defaults.bool(forKey: "bedtimeEnabled")
        else {
            return
        }

        // Create timer that fires every 2 seconds
        persistentBedtimeTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkPersistentBedtime()
        }
    }

    private func checkPersistentBedtime() {
        // Skip if settings window is open
        guard !AppState.shared.isSettingsWindowOpen else {
            return
        }

        guard defaults.bool(forKey: "bedtimePersistent"),
              defaults.bool(forKey: "bedtimeEnabled"),
              let bedtimeStartTime = bedtimeStartTime,
              let bedtimeEndTime = bedtimeEndTime
        else {
            return
        }

        // Don't show if there's already an active overlay
        guard overlayWindows.isEmpty else {
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

        // If we're past bedtime and no overlay is active, show it
        if currentlyInBedtime {
            showBedtimeReminder()
        }
    }

    func checkMiniOverlayTime() {
        // Skip if settings window is open
        guard !AppState.shared.isSettingsWindowOpen else {
            return
        }

        guard defaults.bool(forKey: "miniOverlayEnabled") else {
            return
        }

        let now = Date()
        let intervalMinutes = defaults.integer(forKey: "miniOverlayInterval")
        let intervalSeconds = TimeInterval(intervalMinutes * 60)

        if lastMiniOverlayTime == nil {
            // First time, show immediately
            showScheduledMiniOverlay()
            lastMiniOverlayTime = now
        } else if let lastTime = lastMiniOverlayTime,
                  now.timeIntervalSince(lastTime) >= intervalSeconds
        {
            // Show reminder
            showScheduledMiniOverlay()
            lastMiniOverlayTime = now
        }
    }

    private func showScheduledMiniOverlay() {
        let text = defaults.string(forKey: "miniOverlayText") ?? "Posture check"
        let icon = defaults.string(forKey: "miniOverlayIcon") ?? "sparkles"
        let duration = defaults.object(forKey: "miniOverlayDuration") as? Double ?? 3.15
        let holdDuration = defaults.object(forKey: "miniOverlayHoldDuration") as? Double ?? 1.5
        let verticalOffset = CGFloat(defaults.integer(forKey: "miniOverlayVerticalOffset"))

        // Load custom colors if enabled
        var backgroundColor: Color? = nil
        var foregroundColor: Color? = nil

        if defaults.bool(forKey: "miniOverlayUseCustomColors") {
            if let bgColorData = defaults.data(forKey: "miniOverlayBackgroundColor"),
               let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: bgColorData)
            {
                backgroundColor = Color(nsColor)
            }

            if let fgColorData = defaults.data(forKey: "miniOverlayForegroundColor"),
               let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: fgColorData)
            {
                foregroundColor = Color(nsColor)
            }
        }

        showMiniOverlay(text: text, icon: icon, duration: duration, holdDuration: holdDuration, backgroundColor: backgroundColor, foregroundColor: foregroundColor, verticalOffset: verticalOffset)
    }

    func checkClockOutTime() {
        // Skip if settings window is open
        guard !AppState.shared.isSettingsWindowOpen else {
            return
        }

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
            let reminderInterval = TimeInterval(defaults.integer(forKey: "clockOutReminderInterval") * 60)
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
                    if now.timeIntervalSince(lastBedtimeReminderTime!) >= repeatInterval {
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
}

extension KeyboardShortcuts.Name {
    static let dismissOverlay = Self("dismissOverlay")
}
