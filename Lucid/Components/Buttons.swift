// Buttons.swift

import SwiftUI

struct UIButton: View {
    let action: () -> Void
    let label: String?
    let icon: String?
    let width: CGFloat?
    let height: CGFloat?
    let align: Alignment?
    let destructive: Bool

    @State private var isHovered = false

    init(
        action: @escaping () -> Void,
        destructive: Bool = false,
        label: String? = nil,
        icon: String? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        align: Alignment? = nil
    ) {
        self.action = action
        self.destructive = destructive
        self.label = label
        self.icon = icon
        self.width = width
        self.height = height
        self.align = align
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if align == .trailing {
                    Spacer()
                }
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Style.Icon.sizeSM)).frame(width: Style.Icon.size)
                }
                if label != nil {
                    Text(label ?? "")
                }
                if align == .leading {
                    Spacer()
                }
            }
            .padding(Style.Layout.padding)
            .frame(width: width, height: height ?? Style.Button.height)
            .background(
                isHovered && destructive ? Color.red.opacity(0.2) :
                isHovered ? Style.Button.bg.opacity(1.5) : Style.Button.bg
            )
            .clipShape(
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
            )
            .contentShape(
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
                    .stroke(
                        isHovered && destructive ? Color.red :
                        isHovered ? Style.Button.border.opacity(1.5) : Style.Button.border,
                        lineWidth: Style.Layout.borderWidth
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct UIButtonPlain: View {
    let action: () -> Void
    let label: String?
    let icon: String?
    let width: CGFloat?
    let height: CGFloat?
    let align: Alignment?

    @State private var isHovered = false

    init(
        action: @escaping () -> Void,
        label: String? = nil,
        icon: String? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        align: Alignment? = nil
    ) {
        self.action = action
        self.label = label
        self.icon = icon
        self.width = width
        self.height = height
        self.align = align
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if align == .trailing {
                    Spacer()
                }
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: Style.Icon.sizeSM)).frame(width: Style.Icon.size)
                }
                if label != nil {
                    Text(label ?? "")
                }
                if align == .leading {
                    Spacer()
                }
            }
            .padding(Style.Layout.padding)
            .frame(width: width, height: height ?? Style.Button.height)
            .background(isHovered ? Style.Button.bg.opacity(0.5) : .clear)
            .contentShape(
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
                    .fill(.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
