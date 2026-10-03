import SwiftUI

/// Horizontally scrolling filter chips: All, Favorites, each folder, and "New Folder".
struct ScopeBar: View {
    @Binding var scope: LibraryScope
    let folders: [Folder]
    let onNewFolder: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: Text("All"), symbol: "tray.full", value: .all)
                chip(title: Text("Favorites"), symbol: "star", value: .favorites)
                ForEach(folders) { folder in
                    chip(title: Text(folder.name), symbol: "folder", value: .folder(folder.id))
                }
                Button(action: onNewFolder) {
                    Label("New Folder", systemImage: "plus")
                        .labelStyle(.iconOnly)
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 36, height: 34)
                        .background(Color(.secondarySystemFill), in: .capsule)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
        }
        .scrollClipDisabled()
        .sensoryFeedback(.selection, trigger: scope)
    }

    private func chip(title: Text, symbol: String, value: LibraryScope) -> some View {
        let isSelected = scope == value
        return Button {
            withAnimation(.snappy(duration: 0.2)) { scope = value }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: isSelected ? "\(symbol).fill" : symbol)
                    .font(.caption.weight(.semibold))
                title
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .frame(height: 34)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .background(
                isSelected ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(Color(.secondarySystemFill)),
                in: .capsule
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
