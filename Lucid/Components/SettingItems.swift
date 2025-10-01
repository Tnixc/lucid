import SwiftUI

struct SettingItem<Content: View>: View {
    let title: String
    let description: String
    let icon: String
    let content: () -> Content

    var body: some View {
        HStack(spacing: Style.Layout.paddingSM) {
            Image(systemName: icon)
                .renderingMode(.template)
                .font(.title3)
                .frame(width: Style.Icon.size, height: Style.Icon.size)
            VStack(alignment: .leading) {
                Text(title)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            content()
        }
        .padding(Style.Layout.padding)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius + 2)
                    .fill(Style.Settings.itembg)
                RoundedRectangle(cornerRadius: Style.Layout.cornerRadius + 2)
                    .stroke(
                        Style.Settings.itemBorder,
                        lineWidth: Style.Layout.borderWidth
                    )
            }
        )
    }
}

struct SettingItemRow<Content: View>: View {
    let title: String
    let description: String
    let icon: String
    let content: () -> Content

    var body: some View {
        HStack(spacing: Style.Layout.paddingSM) {
            Image(systemName: icon)
                .renderingMode(.template)
                .font(.title3)
                .frame(width: Style.Icon.size, height: Style.Icon.size)
            VStack(alignment: .leading) {
                Text(title)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            content()
        }
    }
}

struct SettingItemGroup<Content: View>: View {
    let content: () -> Content

    var body: some View {
        content()
            .padding(Style.Layout.padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: Style.Layout.cornerRadius + 2)
                        .fill(Style.Settings.itembg)
                    RoundedRectangle(cornerRadius: Style.Layout.cornerRadius + 2)
                        .stroke(
                            Style.Settings.itemBorder,
                            lineWidth: Style.Layout.borderWidth
                        )
                }
            )
    }
}
