//
//  SoundManager.swift
//  Lucid
//
//  Manages sound effects for reminders and notifications.
//

import AVFoundation
import Cocoa

class SoundManager {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?
    private let defaults = UserDefaults.standard

    private init() {}

    /// Available system sounds
    enum SoundEffect: String, CaseIterable {
        case none = "None"
        case glass = "Glass"
        case hero = "Hero"
        case morse = "Morse"
        case ping = "Ping"
        case pop = "Pop"
        case purr = "Purr"
        case sosumi = "Sosumi"
        case submarine = "Submarine"
        case tink = "Tink"

        var displayName: String {
            rawValue
        }

        var systemSoundName: String? {
            switch self {
            case .none: return nil
            case .glass: return "Glass"
            case .hero: return "Hero"
            case .morse: return "Morse"
            case .ping: return "Ping"
            case .pop: return "Pop"
            case .purr: return "Purr"
            case .sosumi: return "Sosumi"
            case .submarine: return "Submarine"
            case .tink: return "Tink"
            }
        }
    }

    /// Play sound for a reminder if sounds are enabled
    func playReminderSound() {
        guard defaults.bool(forKey: "soundEffectsEnabled") else {
            return
        }

        guard let soundName = defaults.string(forKey: "reminderSoundEffect"),
              let sound = SoundEffect(rawValue: soundName),
              sound != .none
        else {
            return
        }

        playSound(sound)
    }

    /// Play a specific sound effect
    func playSound(_ sound: SoundEffect) {
        guard let systemSoundName = sound.systemSoundName else {
            return
        }

        // Try to play system sound
        if let soundURL = getSystemSoundURL(name: systemSoundName) {
            playAudioFile(at: soundURL)
        } else {
            // Fallback to NSSound
            NSSound(named: systemSoundName)?.play()
        }
    }

    private func getSystemSoundURL(name: String) -> URL? {
        // System sounds are located in /System/Library/Sounds/
        let soundPath = "/System/Library/Sounds/\(name).aiff"
        let url = URL(fileURLWithPath: soundPath)

        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }

        return nil
    }

    private func playAudioFile(at url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = Float(defaults.double(forKey: "soundEffectsVolume"))
            audioPlayer?.play()
        } catch {
            // Fallback to NSSound if AVAudioPlayer fails
            NSSound(contentsOf: url, byReference: true)?.play()
        }
    }

    /// Get the currently selected sound
    var currentSound: SoundEffect {
        guard let soundName = defaults.string(forKey: "reminderSoundEffect"),
              let sound = SoundEffect(rawValue: soundName)
        else {
            return .ping // Default
        }
        return sound
    }

    /// Get the current volume (0.0 - 1.0)
    var currentVolume: Double {
        let volume = defaults.double(forKey: "soundEffectsVolume")
        return volume > 0 ? volume : 0.5 // Default to 50%
    }
}
