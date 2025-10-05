import Combine
import SwiftUI

class MenuBarModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    @Published var eyeStrainCountdown: String = "20:00"
    @Published var bedtimeCountdown: String = "--:--"
    @Published var miniOverlayCountdown: String = "--:--"
    @Published var eyeStrainEnabled: Bool = false
    @Published var bedtimeEnabled: Bool = false
    @Published var miniOverlayEnabled: Bool = false
    
    private var timer: Timer?
    private var eyeStrainRemainingTime: TimeInterval = 20 * 60
    private var miniOverlayRemainingTime: TimeInterval = 0
    private let notifier = Notifier.shared
    private let defaults = UserDefaults.standard

    init() {
        loadSettings()
        resetAllTimers()
        startTimer()
        observeOverlayState()
    }
    
    private func observeOverlayState() {
        // Observe overlay state changes to pause/resume timer
        AppState.shared.$isOverlayActive
            .sink { _ in
                // Timer logic will check isOverlayActive before decrementing
            }
            .store(in: &cancellables)
    }
    
    private func loadSettings() {
        eyeStrainEnabled = defaults.bool(forKey: "eyeStrainEnabled")
        bedtimeEnabled = defaults.bool(forKey: "bedtimeEnabled")
        miniOverlayEnabled = defaults.object(forKey: "miniOverlayEnabled") as? Bool ?? false
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            [weak self] _ in
            self?.updateCountdowns()
        }
    }

    private func updateCountdowns() {
        // Load current settings in case they changed
        loadSettings()
        
        // Skip countdown updates if overlay is active (paused)
        let shouldPause = AppState.shared.isOverlayActive
        
        // Update eye strain timer
        if eyeStrainEnabled && !shouldPause {
            eyeStrainRemainingTime -= 1
            if eyeStrainRemainingTime <= 0 {
                notifier.showEyeStrainReminder()
                let interval = defaults.integer(forKey: "eyeStrainInterval")
                eyeStrainRemainingTime = TimeInterval(interval) * 60
            }
        }
        
        // Always update display even when paused
        if eyeStrainEnabled {
            let minutes = Int(eyeStrainRemainingTime) / 60
            let seconds = Int(eyeStrainRemainingTime) % 60
            DispatchQueue.main.async {
                self.eyeStrainCountdown = String(format: "%02d:%02d", minutes, seconds)
            }
        }
        
        // Update mini overlay timer
        if miniOverlayEnabled && !shouldPause {
            miniOverlayRemainingTime -= 1
            if miniOverlayRemainingTime <= 0 {
                let interval = defaults.integer(forKey: "miniOverlayInterval")
                miniOverlayRemainingTime = TimeInterval(interval) * 60
            }
        }
        
        // Always update display even when paused
        if miniOverlayEnabled {
            let minutes = Int(miniOverlayRemainingTime) / 60
            let seconds = Int(miniOverlayRemainingTime) % 60
            DispatchQueue.main.async {
                self.miniOverlayCountdown = String(format: "%02d:%02d", minutes, seconds)
            }
        }
        
        // Update bedtime countdown (time until next overlay during bedtime)
        if bedtimeEnabled {
            let now = Date()
            let repeatReminders = defaults.bool(forKey: "bedtimeRepeatReminders")
            let isInBedtime = notifier.isInBedtimeRange(now)
            
            // Only show countdown if we're in bedtime range AND repeat is enabled
            if isInBedtime && repeatReminders {
                // Calculate time until next overlay
                if let lastReminderTime = notifier.lastBedtimeReminderTime {
                    let repeatInterval = TimeInterval(defaults.integer(forKey: "bedtimeRepeatInterval") * 60)
                    let nextReminderTime = lastReminderTime.addingTimeInterval(repeatInterval)
                    let timeUntilNext = nextReminderTime.timeIntervalSince(now)
                    
                    if timeUntilNext > 0 {
                        let minutes = Int(timeUntilNext) / 60
                        let seconds = Int(timeUntilNext) % 60
                        DispatchQueue.main.async {
                            self.bedtimeCountdown = String(format: "%02d:%02d", minutes, seconds)
                        }
                    } else {
                        // Next reminder is due now or overdue
                        DispatchQueue.main.async {
                            self.bedtimeCountdown = "00:00"
                        }
                    }
                } else {
                    // First reminder hasn't fired yet, show waiting state
                    DispatchQueue.main.async {
                        self.bedtimeCountdown = "--:--"
                    }
                }
            } else {
                // Not in bedtime range or repeat not enabled
                DispatchQueue.main.async {
                    self.bedtimeCountdown = "--:--"
                }
            }
        } else {
            // Bedtime not enabled
            DispatchQueue.main.async {
                self.bedtimeCountdown = "--:--"
            }
        }
        
        // Check for bedtime reminder
        notifier.checkBedtimeTime()
        // Check for mini overlay reminder
        notifier.checkMiniOverlayTime()
    }

    func resetAllTimers() {
        let eyeStrainInterval = defaults.integer(forKey: "eyeStrainInterval")
        eyeStrainRemainingTime = TimeInterval(eyeStrainInterval) * 60
        
        let miniOverlayInterval = defaults.integer(forKey: "miniOverlayInterval")
        miniOverlayRemainingTime = TimeInterval(miniOverlayInterval) * 60
    }
    
    func resetTimer() {
        resetAllTimers()
    }
}
