import SwiftUI

struct DocumentGridCell: View {
    let document: ScanDocument
    let isSelecting: Bool
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PaperThumbnail(page: document.coverPage, maxPixelSize: 480, cornerRadius: 12)
                .aspectRatio(0.77, contentMode: .fit)
                .overlay(alignment: .topTrailing) {
                    if isSelecting {
                        SelectionIndicator(isSelected: isSelected)
                            .padding(8)
                    } else if document.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.yellow)
                            .padding(6)
                            .glassCapsule()
                            .padding(6)
                            .accessibilityHidden(true)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    Text(document.pageCount, format: .number)
                        .font(.caption2.weight(.semibold).monospacedDigit())
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .glassCapsule()
                        .padding(6)
                        .accessibilityHidden(true)
                }
                .scaleEffect(isSelecting && isSelected ? 0.96 : 1)
                .animation(.snappy(duration: 0.2), value: isSelected)

            VStack(alignment: .leading, spacing: 2) {
                Text(document.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                Text(document.updatedAt, format: .dateTime.day().month(.abbreviated).year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 2)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(DocumentAccessibility.label(for: document))
    }
}

struct DocumentListRow: View {
    let document: ScanDocument
    let isSelecting: Bool
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            if isSelecting {
                SelectionIndicator(isSelected: isSelected)
            }
            PaperThumbnail(page: document.coverPage, maxPixelSize: 180, cornerRadius: 6)
                .frame(width: 46, height: 60)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(document.title)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                    if document.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
                Text(DocumentAccessibility.subtitle(for: document))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(DocumentAccessibility.label(for: document))
    }
}

struct SelectionIndicator: View {
    let isSelected: Bool

    var body: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.title2)
            .symbolRenderingMode(.palette)
            .foregroundStyle(isSelected ? Color.white : Color.secondary, isSelected ? Color.accentColor : Color.clear)
            .background {
                Circle().fill(.background).padding(2)
            }
            .contentTransition(.symbolEffect(.replace))
            .accessibilityHidden(true)
    }
}

enum DocumentAccessibility {
    static func subtitle(for document: ScanDocument) -> String {
        let pages = String(localized: "\(document.pageCount) pages")
        let date = document.updatedAt.formatted(.dateTime.day().month(.abbreviated).year())
        return "\(date) · \(pages)"
    }

    static func label(for document: ScanDocument) -> Text {
        var label = Text(document.title) + Text(", ") + Text(subtitle(for: document))
        if document.isFavorite {
            label = label + Text(", ") + Text("Favorite")
        }
        return label
    }
}
