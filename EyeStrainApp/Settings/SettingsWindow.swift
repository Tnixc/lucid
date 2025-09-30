import SwiftUI

// Local constants
private enum LocalConstants {
    static let sidebarWidth: CGFloat = 200
}

struct SettingsWindow: View {
    private enum Tabs: Hashable {
        case general
        case eyeStrain
        case bedtime
    }

    @State private var selectedTab: Tabs = .general

    var body: some View {
        HStack {
            sidebar.padding(.bottom, Style.Layout.padding)
            Spacer()
            tabContent.padding(.bottom, Style.Layout.padding)
            Spacer()
        }
        .onAppear {
            AppState.shared.isSettingsWindowOpen = true
        }
        .onDisappear {
            AppState.shared.isSettingsWindowOpen = false
        }
    }

    var sidebar: some View {
        HStack {
            VStack(spacing: Style.Layout.paddingSM) {
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
