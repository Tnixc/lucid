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
        .zIndex(isExpanded ? 200 : -10)
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
            .background(Style.Button.bg)
            .clipShape(RoundedRectangle(cornerRadius: Style.Layout.cornerRadius))
        }
        .buttonStyle(.plain)
        .overlay(
            RoundedRectangle(cornerRadius: Style.Layout.cornerRadius)
                .stroke(Style.Button.border, lineWidth: Style.Layout.borderWidth)
        )
    }

    private var dropdownMenu: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(options, id: \.self) { option in
                dropdownMenuItem(for: option)
            }
        }
        .padding(4)
        .background(.thickMaterial)
        .background(Style.Button.bg)
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
        .zIndex(50)
        .frame(maxHeight: height).fixedSize(horizontal: true, vertical: true)
        .shadow(color: Color.black.opacity(0.1), radius: 20)
    }

    private func dropdownMenuItem(for option: T) -> some View {
        Button(action: { selectOption(option) }) {
            HStack {
                Image(systemName: "checkmark")
                    .scaleEffect(1, anchor: .center)
                    .foregroundColor(selectedOption == option ? .primary : .clear)
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
        }

        .buttonStyle(.borderless)
        .frame(height: itemHeight)
    }

    private func toggleExpanded() {
        onClick?()
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
        onSelect?(option)
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
