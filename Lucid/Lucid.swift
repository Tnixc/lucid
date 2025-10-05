import SwiftUI

@main
struct Lucid: App {
    @StateObject private var menuBarModel = MenuBarModel()

    init() {
        registerDefaults()
    }

    var body: some Scene {
        MainScene()

        MenuBarExtra(menuBarModel.eyeStrainCountdown) {
            MenuBarView()
                .environmentObject(menuBarModel)
                .background(.clear)
        }
        .menuBarExtraStyle(.window)
    }

    private func registerDefaults() {
        let defaults: [String: Any] = [
            // General
            "alertsEnabled": true,
            "launchAtLogin": false,
            "overlayMaterial": "ultraThin",
            "clickToDismiss": true,

            // Eye Strain
            "eyeStrainEnabled": false,
            "eyeStrainInterval": 20,
            "eyeStrainTitle": "Eye Strain Break",
            "eyeStrainMessage": "Look away from the screen and rest your eyes.",
            "eyeStrainDismissAfter": 20,

            // Bedtime
            "bedtimeEnabled": false,
            "bedtimeDismissAfter": 30,
            "bedtimeTitle": "Bedtime Reminder",
            "bedtimeMessage": "It's time to go to bed and get some rest.",
            "bedtimeRepeatReminders": false,
            "bedtimeRepeatInterval": 15,
            "bedtimeAutoDismiss": true,
            "bedtimePersistent": false,

            // Mini Overlay
            "miniOverlayEnabled": false,
            "miniOverlayInterval": 30,
            "miniOverlayText": "Posture check",
            "miniOverlayIcon": "sparkles",
            "miniOverlayDuration": 3.15,
            "miniOverlayHoldDuration": 1.5,
            "miniOverlayVerticalOffset": 60,

            // Sound Effects
            "soundEffectsEnabled": false,
            "reminderSoundEffect": "Ping",
            "soundEffectsVolume": 0.5,

            // Presentation Mode
            "disableDuringPresentation": true,

            // Clock Out
            "clockOutEnabled": false,
            "clockOutUseOverlay": true,
            "clockOutReminderEnabled": false,
            "clockOutReminderInterval": 15,
        ]

        UserDefaults.standard.register(defaults: defaults)
    }
}
