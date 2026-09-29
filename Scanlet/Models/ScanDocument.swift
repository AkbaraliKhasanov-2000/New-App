import Foundation
import SwiftData

/// A scanned document made of one or more ordered pages.
@Model
final class ScanDocument {
    var id: UUID = UUID()
    var title: String = ""
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    var isFavorite: Bool = false
    /// Concatenated OCR text of all pages, used for full-text search in the library.
    var searchableText: String = ""
    var folder: Folder?

    @Relationship(deleteRule: .cascade, inverse: \ScanPage.document)
    var pages: [ScanPage] = []

    init(title: String, folder: Folder? = nil) {
        self.title = title
        self.folder = folder
    }

    /// Pages in their display order.
    var orderedPages: [ScanPage] {
        pages.sorted { $0.index < $1.index }
    }

    var pageCount: Int { pages.count }

    var coverPage: ScanPage? { orderedPages.first }

    /// True when at least one page is still waiting for text recognition.
    var hasPendingRecognition: Bool {
        pages.contains { $0.recognizedText == nil }
    }

    func touch() {
        updatedAt = .now
    }

    /// Rebuilds `searchableText` from the pages' recognized text.
    func rebuildSearchIndex() {
        searchableText = orderedPages
            .compactMap(\.recognizedText)
            .joined(separator: "\n")
    }

    /// Re-numbers pages so indexes are contiguous (0, 1, 2, …).
    func normalizePageIndexes() {
        for (offset, page) in orderedPages.enumerated() where page.index != offset {
            page.index = offset
        }
    }

    /// Default title used for new scans, e.g. "Scan 29 Sep 2026 at 14.05".
    static func defaultTitle(for date: Date = .now) -> String {
        let formatted = date.formatted(.dateTime.day().month(.abbreviated).year().hour().minute())
        return String(localized: "Scan \(formatted)")
    }
}
