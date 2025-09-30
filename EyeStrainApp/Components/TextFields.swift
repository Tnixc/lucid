// TextFields.swift

import SwiftUI

struct UITextField: View {
    @Binding var text: String
    let placeholder: String
    let width: CGFloat?

    @State private var isHovered = false
    @State private var isFocused = false

    init(
        text: Binding<String>,
        placeholder: String = "",
        width: CGFloat? = nil
    ) {
        _text = text
        self.placeholder = placeholder
        self.width = width
    }

    var body: some View {
        TextField(placeholder, text: $text, onEditingChanged: { editing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isFocused = editing
            }
        })
        .textFieldStyle(.plain)
        .padding(Style.Layout.padding)
        .frame(width: width, height: Style.Button.height)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
                    .fill(isFocused ? Style.Button.bg.opacity(2.0) : Style.Button.bg)
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
                    .stroke(
                        isHovered || isFocused ? Style.Button.border.opacity(1.5) : Style.Button.border,
                        lineWidth: Style.Layout.borderWidth
                    )
            }
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct UINumberField: View {
    @Binding var value: Int
    let placeholder: String
    let width: CGFloat?

    @State private var isHovered = false
    @State private var isFocused = false

    init(
        value: Binding<Int>,
        placeholder: String = "",
        width: CGFloat? = nil
    ) {
        _value = value
        self.placeholder = placeholder
        self.width = width
    }

    var body: some View {
        TextField(placeholder, value: $value, formatter: NumberFormatter(), onEditingChanged: { editing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isFocused = editing
            }
        })
        .textFieldStyle(.plain)
        .padding(Style.Layout.padding)
        .frame(width: width, height: Style.Button.height)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
                    .fill(isFocused ? Style.Button.bg.opacity(2.0) : Style.Button.bg)
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
                    .stroke(
                        isHovered || isFocused ? Style.Button.border.opacity(1.5) : Style.Button.border,
                        lineWidth: Style.Layout.borderWidth
                    )
            }
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct UINumberFieldCompact: View {
    @Binding var value: Int
    let placeholder: String
    let width: CGFloat?

    @State private var isHovered = false
    @State private var isFocused = false

    init(
        value: Binding<Int>,
        placeholder: String = "",
        width: CGFloat? = nil
    ) {
        _value = value
        self.placeholder = placeholder
        self.width = width
    }

    var body: some View {
        TextField(placeholder, value: $value, formatter: NumberFormatter(), onEditingChanged: { editing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isFocused = editing
            }
        })
        .textFieldStyle(.plain)
        .monospacedDigit()
        .multilineTextAlignment(.center)
        .font(.system(size: 13, weight: .medium))
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .frame(width: width, height: 24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(isFocused ? Style.Button.bg.opacity(2.0) : Style.Button.bg)
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        isHovered || isFocused ? Style.Button.border.opacity(1.5) : Style.Button.border,
                        lineWidth: Style.Layout.borderWidth
                    )
            }
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
