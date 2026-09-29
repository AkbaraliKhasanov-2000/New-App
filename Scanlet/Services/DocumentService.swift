import Foundation
import PDFKit
import SwiftData
import UIKit

/// Creates, edits and indexes documents. Heavy image work runs off the main actor;
/// SwiftData mutations happen on the main actor.
@MainActor
enum DocumentService {
    /// Rendered page produced off the main actor.
    struct ProcessedPage: Sendable {
        let original: Data
        let rendered: Data
    }

    // MARK: - Creating

    /// Processes captured images and appends them to `document`
    /// (or to a new document when `document` is nil). Returns the document.
    @discardableResult
    static func addPages(
        _ images: [UIImage],
        to document: ScanDocument?,
        folder: Folder?,
        autoCrop: Bool,
        context: ModelContext
    ) async -> ScanDocument {
        let filter = Preferences.defaultFilter
        let processed = await process(images, filter: filter, autoCrop: autoCrop)

        let target: ScanDocument
        if let document {
            target = document
        } else {
            target = ScanDocument(title: ScanDocument.defaultTitle(), folder: folder)
            context.insert(target)
        }

        var nextIndex = (target.pages.map(\.index).max() ?? -1) + 1
        for page in processed {
            let scanPage = ScanPage(index: nextIndex, originalImageData: page.original, imageData: page.rendered, filter: filter)
            scanPage.document = target
            context.insert(scanPage)
            nextIndex += 1
        }
        target.touch()
        try? context.save()

        if Preferences.autoRecognizeText {
            Task { await TextIndexer.shared.index(target, context: context) }
        }
        return target
    }

    /// Renders every page of the PDF files into images.
    nonisolated static func images(fromPDFAt url: URL) async -> [UIImage] {
        await Task.detached(priority: .userInitiated) {
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            guard let pdf = PDFDocument(url: url) else { return [] }
            var images: [UIImage] = []
            for index in 0..<pdf.pageCount {
                guard let page = pdf.page(at: index) else { continue }
                let bounds = page.bounds(for: .mediaBox)
                // Render at ~220 dpi.
                let scale: CGFloat = 220 / 72
                let size = CGSize(width: bounds.width * scale, height: bounds.height * scale)
                images.append(page.thumbnail(of: size, for: .mediaBox))
            }
            return images
        }.value
    }

    nonisolated static func process(_ images: [UIImage], filter: PageFilter, autoCrop: Bool) async -> [ProcessedPage] {
        await Task.detached(priority: .userInitiated) {
            images.map { image in
                autoreleasepool {
                    let base = autoCrop ? ImageProcessor.autoCropped(image) : ImageProcessor.normalized(image)
                    let rendered = ImageProcessor.apply(filter, to: base)
                    return ProcessedPage(
                        original: ImageProcessor.jpegData(base, quality: 0.92),
                        rendered: ImageProcessor.jpegData(rendered, quality: 0.88)
                    )
                }
            }
        }.value
    }

    // MARK: - Editing pages

    static func applyFilter(_ filter: PageFilter, to page: ScanPage) async {
        guard let original = page.originalImageData else { return }
        let rendered = await Task.detached(priority: .userInitiated) { () -> Data? in
            guard let image = UIImage(data: original) else { return nil }
            return ImageProcessor.jpegData(ImageProcessor.apply(filter, to: image), quality: 0.88)
        }.value
        guard let rendered else { return }
        page.filter = filter
        page.replaceRenderedImage(rendered)
        page.document?.touch()
    }

    /// Transforms the original image and re-renders it with the page's filter.
    static func transform(
        _ page: ScanPage,
        context: ModelContext,
        invalidatesText: Bool = true,
        _ transform: @escaping @Sendable (UIImage) -> UIImage
    ) async {
        guard let original = page.originalImageData else { return }
        let filter = page.filter
        let result = await Task.detached(priority: .userInitiated) { () -> ProcessedPage? in
            guard let image = UIImage(data: original) else { return nil }
            let transformed = transform(image)
            let rendered = ImageProcessor.apply(filter, to: transformed)
            return ProcessedPage(
                original: ImageProcessor.jpegData(transformed, quality: 0.92),
                rendered: ImageProcessor.jpegData(rendered, quality: 0.88)
            )
        }.value
        guard let result else { return }
        page.replaceImages(original: result.original, rendered: result.rendered, invalidateText: invalidatesText)
        page.document?.touch()
        try? context.save()

        if invalidatesText, let document = page.document, Preferences.autoRecognizeText {
            Task { await TextIndexer.shared.index(document, context: context) }
        }
    }

    static func rotate(_ page: ScanPage, clockwise: Bool, context: ModelContext) async {
        await transform(page, context: context) { image in
            ImageProcessor.rotated(image, quarterTurns: clockwise ? 1 : -1)
        }
    }

    static func delete(_ page: ScanPage, context: ModelContext) {
        let document = page.document
        document?.pages.removeAll { $0.id == page.id }
        context.delete(page)
        document?.normalizePageIndexes()
        document?.rebuildSearchIndex()
        document?.touch()
        try? context.save()
    }

    static func movePages(in document: ScanDocument, from source: IndexSet, to destination: Int) {
        var pages = document.orderedPages
        pages.move(fromOffsets: source, toOffset: destination)
        for (offset, page) in pages.enumerated() {
            page.index = offset
        }
        document.rebuildSearchIndex()
        document.touch()
    }

    // MARK: - Documents

    static func duplicate(_ document: ScanDocument, context: ModelContext) -> ScanDocument {
        let copy = ScanDocument(title: String(localized: "\(document.title) Copy"), folder: document.folder)
        copy.searchableText = document.searchableText
        context.insert(copy)
        for page in document.orderedPages {
            let pageCopy = ScanPage(
                index: page.index,
                originalImageData: page.originalImageData ?? Data(),
                imageData: page.imageData ?? Data(),
                filter: page.filter
            )
            pageCopy.recognizedText = page.recognizedText
            pageCopy.recognizedLinesData = page.recognizedLinesData
            pageCopy.document = copy
            context.insert(pageCopy)
        }
        try? context.save()
        return copy
    }

    /// Appends the pages of `others` to the first document (in order) and deletes the rest.
    static func merge(_ documents: [ScanDocument], context: ModelContext) -> ScanDocument? {
        guard let target = documents.first else { return nil }
        var nextIndex = (target.pages.map(\.index).max() ?? -1) + 1
        for other in documents.dropFirst() {
            for page in other.orderedPages {
                page.index = nextIndex
                page.document = target
                nextIndex += 1
            }
            other.pages.removeAll()
            context.delete(other)
        }
        target.rebuildSearchIndex()
        target.touch()
        try? context.save()
        return target
    }

    static func delete(_ documents: [ScanDocument], context: ModelContext) {
        for document in documents {
            context.delete(document)
        }
        try? context.save()
    }
}

/// Runs on-device OCR for pages that have not been recognized yet, one page at a time.
@MainActor
final class TextIndexer {
    static let shared = TextIndexer()

    private var inFlight: Set<UUID> = []

    func index(_ document: ScanDocument, context: ModelContext) async {
        let languages = Preferences.recognitionLanguages
        for page in document.orderedPages {
            guard document.modelContext != nil, !document.isDeleted else { return }
            guard page.modelContext != nil, !page.isDeleted,
                  page.recognizedText == nil, !inFlight.contains(page.id),
                  let data = page.imageData ?? page.originalImageData
            else { continue }
            inFlight.insert(page.id)
            let revision = page.revision
            let result = try? await TextRecognizer.recognize(imageData: data, languages: languages)
            inFlight.remove(page.id)
            // Skip stale results if the page changed (or was deleted) while recognizing.
            guard page.modelContext != nil, !page.isDeleted, page.revision == revision else { continue }
            page.recognizedLines = result?.lines ?? []
            page.recognizedText = result?.text ?? ""
        }
        guard document.modelContext != nil, !document.isDeleted else { return }
        document.rebuildSearchIndex()
        try? context.save()
    }

    /// Indexes every document that still has unrecognized pages (e.g. after an interrupted session).
    func indexPending(context: ModelContext) async {
        guard Preferences.autoRecognizeText else { return }
        let descriptor = FetchDescriptor<ScanDocument>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        guard let documents = try? context.fetch(descriptor) else { return }
        for document in documents where document.hasPendingRecognition {
            await index(document, context: context)
        }
    }

    /// Recognizes a single page immediately, regardless of the auto-recognition setting.
    func recognize(_ page: ScanPage, context: ModelContext) async {
        guard let data = page.imageData ?? page.originalImageData, !inFlight.contains(page.id) else { return }
        inFlight.insert(page.id)
        defer { inFlight.remove(page.id) }
        let revision = page.revision
        let result = try? await TextRecognizer.recognize(imageData: data, languages: Preferences.recognitionLanguages)
        guard page.modelContext != nil, !page.isDeleted, page.revision == revision else { return }
        page.recognizedLines = result?.lines ?? []
        page.recognizedText = result?.text ?? ""
        page.document?.rebuildSearchIndex()
        try? context.save()
    }
}
