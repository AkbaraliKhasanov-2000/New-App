import SwiftUI

struct DocumentGridCell: View {
    let document: ScanDocument
    let isSelecting: Bool
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Close to A4 proportions so pages are shown whole, not cropped.
            PaperThumbnail(page: document.coverPage, maxPixelSize: 360, cornerRadius: 8)
                .aspectRatio(0.72, contentMode: .fit)
                .overlay {
                    if isSelecting && isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.accentColor, lineWidth: 3)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if isSelecting {
                        SelectionIndicator(isSelected: isSelected)
                            .padding(6)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if document.isFavorite && !isSelecting {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.yellow.gradient, in: .circle)
                            .padding(5)
                            .accessibilityHidden(true)
                    }
                }
                .scaleEffect(isSelecting && isSelected ? 0.95 : 1)
                .animation(.snappy(duration: 0.2), value: isSelected)

            VStack(alignment: .leading, spacing: 1) {
                Text(document.title)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                Text(DocumentAccessibility.shortSubtitle(for: document))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
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

    /// Compact "Sep 29 · 3 pages" for the grid.
    static func shortSubtitle(for document: ScanDocument) -> String {
        let date = document.updatedAt.formatted(.dateTime.day().month(.abbreviated))
        return "\(date) · \(String(localized: "\(document.pageCount) pages"))"
    }

    static func label(for document: ScanDocument) -> Text {
        var label = Text(document.title) + Text(", ") + Text(subtitle(for: document))
        if document.isFavorite {
            label = label + Text(", ") + Text("Favorite")
        }
        return label
    }
}
