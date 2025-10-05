import Combine
import SwiftUI

class MenuBarModel: ObservableObject {
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
        
        // Update eye strain timer
        if eyeStrainEnabled {
            eyeStrainRemainingTime -= 1
            if eyeStrainRemainingTime <= 0 {
                notifier.showEyeStrainReminder()
                let interval = defaults.integer(forKey: "eyeStrainInterval")
                eyeStrainRemainingTime = TimeInterval(interval) * 60
            }
            let minutes = Int(eyeStrainRemainingTime) / 60
            let seconds = Int(eyeStrainRemainingTime) % 60
            DispatchQueue.main.async {
                self.eyeStrainCountdown = String(format: "%02d:%02d", minutes, seconds)
            }
        }
        
        // Update mini overlay timer
        if miniOverlayEnabled {
            miniOverlayRemainingTime -= 1
            if miniOverlayRemainingTime <= 0 {
                let interval = defaults.integer(forKey: "miniOverlayInterval")
                miniOverlayRemainingTime = TimeInterval(interval) * 60
            }
            let minutes = Int(miniOverlayRemainingTime) / 60
            let seconds = Int(miniOverlayRemainingTime) % 60
            DispatchQueue.main.async {
                self.miniOverlayCountdown = String(format: "%02d:%02d", minutes, seconds)
            }
        }
        
        // Update bedtime countdown (time until bedtime start)
        if bedtimeEnabled {
            if let startTime = defaults.object(forKey: "bedtimeStartTime") as? Date {
                let calendar = Calendar.current
                let now = Date()
                let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
                
                var nextBedtime = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: now))!
                nextBedtime = calendar.date(bySettingHour: startComponents.hour ?? 22, minute: startComponents.minute ?? 0, second: 0, of: nextBedtime)!
                
                // If bedtime has already passed today, show tomorrow's bedtime
                if nextBedtime <= now {
                    nextBedtime = calendar.date(byAdding: .day, value: 1, to: nextBedtime)!
                }
                
                let timeInterval = nextBedtime.timeIntervalSince(now)
                let hours = Int(timeInterval) / 3600
                let minutes = (Int(timeInterval) % 3600) / 60
                
                DispatchQueue.main.async {
                    self.bedtimeCountdown = String(format: "%02d:%02d", hours, minutes)
                }
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
