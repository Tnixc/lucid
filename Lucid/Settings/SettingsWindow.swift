import Foundation
import SwiftUI
import AppKit

// Local constants
private enum LocalConstants {
    static let sidebarWidth: CGFloat = 200
}

struct SettingsWindow: View {
    private enum Tabs: Hashable {
        case general
        case eyeStrain
        case bedtime
        case miniOverlay
    }

    @State private var selectedTab: Tabs = .general
    @StateObject private var windowObserver = SettingsWindowObserver()

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar border divider
            Divider()

            HStack {
                sidebar.padding(.bottom, Style.Layout.padding)
                Spacer()
                tabContent.padding(.bottom, Style.Layout.padding)
                Spacer()
            }
        }
        .background(WindowAccessor(windowObserver: windowObserver))
    }

    var sidebar: some View {
        HStack {
            VStack(spacing: Style.Layout.paddingSM) {
                Spacer().frame(height: Style.Layout.paddingSM)
                SettingsTabButton(
                    title: "General",
                    icon: "gear",
                    isSelected: selectedTab == .general
                ) {
                    selectedTab = .general
                }

                SettingsTabButton(
                    title: "Eye Strain",
                    icon: "eye",
                    isSelected: selectedTab == .eyeStrain
                ) {
                    selectedTab = .eyeStrain
                }

                SettingsTabButton(
                    title: "Bedtime",
                    icon: "moon",
                    isSelected: selectedTab == .bedtime
                ) {
                    selectedTab = .bedtime
                }

                SettingsTabButton(
                    title: "Mini Overlay",
                    icon: "circle.dashed.inset.fill",
                    isSelected: selectedTab == .miniOverlay
                ) {
                    selectedTab = .miniOverlay
                }
                Spacer()
            }
            Divider()
        }.padding(.leading, Style.Layout.padding)
    }

    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .general:
            GeneralSettingsTab()
        case .eyeStrain:
            EyeStrainSettingsTab()
        case .bedtime:
            BedtimeSettingsTab()
        case .miniOverlay:
            MiniOverlaySettingsTab()
        }
    }
}

struct SettingsTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        if isSelected {
            UIButton(
                action: action,
                label: title,
                icon: icon,
                width: LocalConstants.sidebarWidth,
                height: Style.Button.heightSM,
                align: .leading
            )
        } else {
            UIButtonPlain(
                action: action,
                label: title,
                icon: icon,
                width: LocalConstants.sidebarWidth,
                height: Style.Button.heightSM,
                align: .leading
            )
        }
    }
}

// MARK: - Window Focus Observer

class SettingsWindowObserver: NSObject, ObservableObject {
    weak var window: NSWindow? {
        didSet {
            setupObservers()
        }
    }
    
    private func setupObservers() {
        guard let window = window else { return }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidBecomeKey),
            name: NSWindow.didBecomeKeyNotification,
            object: window
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResignKey),
            name: NSWindow.didResignKeyNotification,
            object: window
        )
    }
    
    @objc private func windowDidBecomeKey() {
        AppState.shared.isSettingsWindowFocused = true
    }
    
    @objc private func windowDidResignKey() {
        AppState.shared.isSettingsWindowFocused = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        AppState.shared.isSettingsWindowFocused = false
    }
}

// MARK: - Window Accessor

struct WindowAccessor: NSViewRepresentable {
    let windowObserver: SettingsWindowObserver
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.windowObserver.window = window
                // Check initial focus state
                if window.isKeyWindow {
                    AppState.shared.isSettingsWindowFocused = true
                }
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if windowObserver.window == nil, let window = nsView.window {
            windowObserver.window = window
        }
    }
}
