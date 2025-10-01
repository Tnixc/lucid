import Combine
import SwiftUI

class MenuBarModel: ObservableObject {
    @Published var countdown: String = "20:00"
    private var timer: Timer?
    private var remainingTime: TimeInterval = 20 * 60 // 20 minutes in seconds
    private let notifier = Notifier.shared
    private let defaults = UserDefaults.standard

    init() {
        resetTimer()
        startTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [weak self] _ in
            self?.updateCountdown()
        }
    }

    private func updateCountdown() {
        remainingTime -= 1
        if remainingTime <= 0 {
            // Trigger eye strain reminder if enabled
            if defaults.bool(forKey: "eyeStrainEnabled") {
                notifier.showEyeStrainReminder()
            }
            let interval = defaults.integer(forKey: "eyeStrainInterval")
            remainingTime = TimeInterval(interval) * 60 // Reset
        }
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        DispatchQueue.main.async {
            self.countdown = String(format: "%02d:%02d", minutes, seconds)
        }
        // Check for bedtime reminder
        notifier.checkBedtimeTime()
        // Check for mini overlay reminder
        notifier.checkMiniOverlayTime()
    }

    func resetTimer() {
        let interval = defaults.integer(forKey: "eyeStrainInterval")
        remainingTime = TimeInterval(interval) * 60
    }
}
