import Foundation
import SwiftData

/// A single page of a `ScanDocument`.
///
/// The untouched capture is kept in `originalImageData` so filters can be changed
/// at any time without losing quality; `imageData` holds the rendered result.
@Model
final class ScanPage {
    var id: UUID = UUID()
    var index: Int = 0
    var createdAt: Date = Date.now

    @Attribute(.externalStorage) var originalImageData: Data?
    @Attribute(.externalStorage) var imageData: Data?

    var filterRawValue: String = PageFilter.enhanced.rawValue
    /// Incremented every time the rendered image changes; used as a cache key.
    var revision: Int = 0

    /// Recognized text. `nil` means recognition has not run yet.
    var recognizedText: String?
    /// JSON-encoded `[RecognizedLine]` with normalized bounding boxes.
    var recognizedLinesData: Data?

    var document: ScanDocument?

    init(index: Int, originalImageData: Data, imageData: Data, filter: PageFilter) {
        self.index = index
        self.originalImageData = originalImageData
        self.imageData = imageData
        self.filterRawValue = filter.rawValue
    }

    var filter: PageFilter {
        get { PageFilter(rawValue: filterRawValue) ?? .enhanced }
        set { filterRawValue = newValue.rawValue }
    }

    var recognizedLines: [RecognizedLine] {
        get {
            guard let recognizedLinesData else { return [] }
            return (try? JSONDecoder().decode([RecognizedLine].self, from: recognizedLinesData)) ?? []
        }
        set {
            recognizedLinesData = try? JSONEncoder().encode(newValue)
        }
    }

    /// Cache key that changes whenever the rendered image changes.
    var cacheKey: String { "\(id.uuidString)-\(revision)" }

    /// Replaces the page images and invalidates previous recognition results.
    func replaceImages(original: Data, rendered: Data, invalidateText: Bool) {
        originalImageData = original
        imageData = rendered
        revision += 1
        if invalidateText {
            recognizedText = nil
            recognizedLinesData = nil
        }
    }

    /// Replaces only the rendered image (e.g. when the filter changes).
    func replaceRenderedImage(_ rendered: Data) {
        imageData = rendered
        revision += 1
    }

    /// Snapshot that can safely cross concurrency domains for export work.
    var snapshot: PageSnapshot {
        PageSnapshot(id: id, imageData: imageData ?? originalImageData ?? Data(), lines: recognizedLines, text: recognizedText ?? "")
    }
}

/// Immutable, `Sendable` copy of a page used by background export and OCR tasks.
struct PageSnapshot: Sendable, Identifiable {
    let id: UUID
    let imageData: Data
    let lines: [RecognizedLine]
    let text: String
}
