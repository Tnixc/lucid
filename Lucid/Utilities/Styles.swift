// styles.swift
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (
                255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
            )
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

enum Style {
    enum Colors {
        static let accent: Color = .blue
        static let nightTime: Color = .blue
        static let morningTime: Color = .orange
        static let barFill: Gradient = .init(colors: [
            Style.Colors.nightTime, Style.Colors.morningTime,
        ])
    }

    enum Layout {
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 10
        static let paddingSM: CGFloat = 5
        static let borderWidth: CGFloat = 1
    }

    enum Button {
        static let height: CGFloat = 40
        static let heightSM: CGFloat = 36
        static let heightXS: CGFloat = 24
        static let bg = Color.secondary.opacity(0.1)
        static let border = Color.secondary.opacity(0.3)
    }

    enum Icon {
        static let size: CGFloat = 20
        static let sizeSM: CGFloat = 14
    }

    enum Timeline {
        static let bg = Colors.accent.opacity(0.1)
        static let border = Colors.accent.opacity(0.3)
    }

    enum Box {
        static let bg = Color.secondary.opacity(0.1)
        static let border = Color.secondary.opacity(0.2)
    }

    enum Settings {
        static let itembg = Color.secondary.opacity(0.1)
        static let itemBorder = Color.secondary.opacity(0.2)
    }
}
