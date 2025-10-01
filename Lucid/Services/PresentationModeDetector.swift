//
//  PresentationModeDetector.swift
//  Lucid
//
//  Detects when the user is in presentation mode or screen sharing.
//  Used to automatically disable reminders during presentations.
//

import Cocoa
import Foundation

class PresentationModeDetector {
    static let shared = PresentationModeDetector()

    private var isScreenBeingCaptured = false
    private var checkTimer: Timer?

    private init() {
        startMonitoring()
    }

    /// Start monitoring for screen capture and presentation apps
    func startMonitoring() {
        // Check every 5 seconds
        checkTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateCaptureStatus()
        }

        // Initial check
        updateCaptureStatus()
    }

    /// Stop monitoring
    func stopMonitoring() {
        checkTimer?.invalidate()
        checkTimer = nil
    }

    /// Returns true if presentation mode is active
    var isPresentationModeActive: Bool {
        return isScreenBeingCaptured || isPresentationAppActive
    }

    // MARK: - Screen Capture Detection

    private func updateCaptureStatus() {
        isScreenBeingCaptured = checkScreenCapture()
    }

    private func checkScreenCapture() -> Bool {
        // Check if any screen is being captured
        for screen in NSScreen.screens {
            // On macOS 10.15+, we can check if screen is being captured
            if #available(macOS 10.15, *) {
                // Check if screen is being recorded
                // Note: This requires screen recording permission
                if screen.displayID != 0 {
                    // Screen is potentially being captured
                    // We'll use a more reliable method below
                }
            }
        }

        // Check for active screen recording by looking at running processes
        return isScreenRecordingActive()
    }

    private func isScreenRecordingActive() -> Bool {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications

        // Common screen sharing/recording apps
        let screenSharingBundleIDs = [
            "com.apple.QuickTimePlayerX", // QuickTime screen recording
            "us.zoom.xos", // Zoom
            "com.microsoft.teams", // Microsoft Teams
            "com.webex.meetingmanager", // Cisco Webex
            "com.google.Chrome", // Google Meet (Chrome)
            "com.microsoft.edgemac", // Microsoft Edge
            "com.skype.skype", // Skype
            "com.discord.Discord", // Discord
            "com.reincubate.camo", // Camo
            "us.zoom.ringcentral", // RingCentral
            "com.logmein.GoToMeeting", // GoToMeeting
            "com.bluejeans.BlueJeansApp", // BlueJeans
            "com.8x8.meetings", // 8x8
        ]

        // Check if any screen sharing app is active and frontmost
        for app in runningApps {
            if let bundleID = app.bundleIdentifier {
                if screenSharingBundleIDs.contains(bundleID) && app.isActive {
                    // Only consider it presentation mode if the app is frontmost/active
                    return true
                }
            }
        }

        return false
    }

    // MARK: - Presentation App Detection

    private var isPresentationAppActive: Bool {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications

        // Presentation software
        let presentationBundleIDs = [
            "com.apple.iWork.Keynote", // Keynote
            "com.microsoft.Powerpoint", // PowerPoint
            "com.google.Chrome.app.kjgfgldnnfoeklkmfkjfagphfdbfjjlk", // Google Slides (Chrome app)
            "com.prezi.PreziNext", // Prezi
            "com.readdle.PDFExpert-Mac", // PDF Expert (presentation mode)
            "com.apple.Preview", // Preview (presentation mode)
        ]

        // Check if any presentation app is active and frontmost
        for app in runningApps {
            if let bundleID = app.bundleIdentifier {
                if presentationBundleIDs.contains(bundleID) && app.isActive {
                    // Additional check: see if it's in fullscreen
                    if isAppInFullscreen(app) {
                        return true
                    }
                }
            }
        }

        return false
    }

    private func isAppInFullscreen(_ app: NSRunningApplication) -> Bool {
        // Check if the app has fullscreen windows
        guard let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
            return false
        }

        for window in windows {
            // Check if window belongs to this app
            if let windowOwnerPID = window[kCGWindowOwnerPID as String] as? Int32,
               windowOwnerPID == app.processIdentifier
            {
                // Check if window is fullscreen by comparing bounds to screen size
                if let bounds = window[kCGWindowBounds as String] as? [String: CGFloat],
                   let x = bounds["X"],
                   let y = bounds["Y"],
                   let width = bounds["Width"],
                   let height = bounds["Height"]
                {
                    // Check if window roughly matches screen size (with some tolerance)
                    for screen in NSScreen.screens {
                        let screenFrame = screen.frame
                        if abs(width - screenFrame.width) < 10 && abs(height - screenFrame.height) < 10 {
                            return true
                        }
                    }
                }
            }
        }

        return false
    }
}

// Helper extension to get display ID
extension NSScreen {
    var displayID: CGDirectDisplayID {
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        guard let screenNumber = deviceDescription[key] as? NSNumber else {
            return 0
        }
        return CGDirectDisplayID(screenNumber.uint32Value)
    }
}
