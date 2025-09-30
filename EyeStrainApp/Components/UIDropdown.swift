import SwiftUI

struct UIDropdown<T: Hashable>: View {
    @Binding var selectedOption: T
    private let options: [T]
    private let optionToString: (T) -> String
    private let width: CGFloat
    private let height: CGFloat
    private let onSelect: ((T) -> Void)?
    private let onClick: (() -> Void)?

    @State private var isExpanded = false
    @State private var isButtonEnabled = true
    @State private var isButtonHovered = false

    private let itemHeight = 28.0

    init(
        selectedOption: Binding<T>,
        options: [T],
        optionToString: @escaping (T) -> String,
        width: CGFloat,
        height: CGFloat,
        onSelect: ((T) -> Void)? = nil,
        onClick: (() -> Void)? = nil
    ) {
        _selectedOption = selectedOption
        self.options = options
        self.optionToString = optionToString
        self.width = width
        self.height = height
        self.onSelect = onSelect
        self.onClick = onClick
    }

    var body: some View {
        ZStack(alignment: .top) {
            if isExpanded {
                selectionButton
                dropdownMenu
            } else {
                selectionButton
            }
        }
        .zIndex(isExpanded ? 1000 : -10)
        .onAppear {
            setupMouseEventMonitor()
        }
    }

    private var selectionButton: some View {
        Button(action: toggleExpanded) {
            HStack {
                Text(optionToString(selectedOption))
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
            }
            .padding()
            .frame(width: width, height: height)
            .background(isButtonHovered ? Style.Button.bg.opacity(1.5) : Style.Button.bg)
            .clipShape(RoundedRectangle(cornerRadius: Style.Layout.cornerRadius))
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
                .stroke(isButtonHovered ? Style.Button.border.opacity(1.5) : Style.Button.border, lineWidth: Style.Layout.borderWidth)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isButtonHovered = hovering
            }
        }
    }

    private var dropdownMenu: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(options, id: \.self) { option in
                dropdownMenuItem(for: option)
            }
        }
        .padding(4)
        .background(.thickMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: Style.Layout.cornerRadius + 2)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: Style.Layout.cornerRadius + 2))
        .frame(width: width)
        .position(
            x: width / 2,
            y: itemHeight / 2 * CGFloat(options.count) + itemHeight * 2 - 6
        )
        .transition(.blurReplace)
        .zIndex(2000)
        .frame(maxHeight: height).fixedSize(horizontal: true, vertical: true)
        .shadow(color: Color.black.opacity(0.1), radius: 20)
    }

    private func dropdownMenuItem(for option: T) -> some View {
        DropdownMenuItemView(
            option: option,
            isSelected: selectedOption == option,
            optionToString: optionToString,
            itemHeight: itemHeight,
            onSelect: { selectOption(option) }
        )
    }

    private func toggleExpanded() {
        if let onClick = onClick {
            onClick()
        }
        guard isButtonEnabled else { return }

        withAnimation(.snappy(duration: 0.15)) {
            isExpanded.toggle()
        }

        isButtonEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isButtonEnabled = true
        }
    }

    private func selectOption(_ option: T) {
        selectedOption = option
        if let onSelect = onSelect {
            onSelect(option)
        }
        toggleExpanded()
    }

    private func setupMouseEventMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp]) {
            event in
            if isExpanded {
                DispatchQueue.main.async {
                    toggleExpanded()
                }
            }
            return event
        }
    }
}

struct DropdownMenuItemView<T: Hashable>: View {
    let option: T
    let isSelected: Bool
    let optionToString: (T) -> String
    let itemHeight: CGFloat
    let onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: "checkmark")
                    .scaleEffect(1, anchor: .center)
                    .foregroundColor(isSelected ? .primary : .clear)
                    .fontWeight(.medium)
                    .frame(width: 15)
                    .padding(.leading, Style.Layout.padding)
                Text(optionToString(option))
                    .foregroundColor(.primary)
                    .padding(.vertical)
                    .frame(height: itemHeight)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isHovered ? Color.secondary.opacity(0.15) : Color.clear)
            .cornerRadius(Style.Layout.cornerRadius)
        }
        .buttonStyle(.borderless)
        .frame(height: itemHeight)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }
}
