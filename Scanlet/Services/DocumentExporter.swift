import CoreText
import PDFKit
import UIKit

struct ExportOptions: Sendable {
    var paperSize: PaperSize = .automatic
    var quality: ExportQuality = .balanced
    /// Adds an invisible OCR text layer so the PDF is searchable and selectable.
    var includeTextLayer = true
    /// Free plan exports carry a small footer.
    var addWatermark = false
    var password: String?
}

/// Builds shareable files (searchable PDF, JPG, TXT) from page snapshots.
enum DocumentExporter {
    enum Failure: LocalizedError {
        case noPages
        case writeFailed

        var errorDescription: String? {
            switch self {
            case .noPages: String(localized: "This document has no pages to export.")
            case .writeFailed: String(localized: "The file couldn’t be created. Please try again.")
            }
        }
    }

    // MARK: - Public

    static func export(
        pages: [PageSnapshot],
        title: String,
        format: ExportFormat,
        options: ExportOptions
    ) async throws -> [URL] {
        guard !pages.isEmpty else { throw Failure.noPages }
        return try await Task.detached(priority: .userInitiated) {
            let folder = try makeExportFolder()
            let baseName = sanitizedFileName(title)
            switch format {
            case .pdf:
                let url = folder.appendingPathComponent(baseName).appendingPathExtension("pdf")
                try writePDF(pages: pages, to: url, options: options)
                return [url]
            case .images:
                return try writeImages(pages: pages, baseName: baseName, folder: folder, options: options)
            case .text:
                let url = folder.appendingPathComponent(baseName).appendingPathExtension("txt")
                let text = pages.map(\.text).joined(separator: "\n\n")
                try text.write(to: url, atomically: true, encoding: .utf8)
                return [url]
            }
        }.value
    }

    /// Removes files from previous exports.
    static func purgeOldExports() {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("Exports", isDirectory: true)
        try? FileManager.default.removeItem(at: root)
    }

    // MARK: - PDF

    static func writePDF(pages: [PageSnapshot], to url: URL, options: ExportOptions) throws {
        let metadata: [String: Any] = [
            kCGPDFContextCreator as String: "Scanlet",
            kCGPDFContextTitle as String: url.deletingPathExtension().lastPathComponent,
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = metadata

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792), format: format)
        try renderer.writePDF(to: url) { context in
            for page in pages {
                autoreleasepool {
                    guard let image = UIImage(data: page.imageData) else { return }
                    let pageRect = CGRect(origin: .zero, size: pageSize(for: image.size, paper: options.paperSize))
                    context.beginPage(withBounds: pageRect, pageInfo: [:])

                    let imageRect = aspectFitRect(for: image.size, in: pageRect.insetBy(
                        dx: options.paperSize == .automatic ? 0 : 18,
                        dy: options.paperSize == .automatic ? 0 : 18
                    ))
                    let embedded = downsampledJPEG(image, for: imageRect.size, quality: options.quality) ?? image
                    embedded.draw(in: imageRect)

                    if options.includeTextLayer {
                        drawInvisibleText(page.lines, in: imageRect, context: context.cgContext)
                    }
                    if options.addWatermark {
                        drawWatermark(in: pageRect)
                    }
                }
            }
        }

        if let password = options.password, !password.isEmpty {
            try encrypt(url: url, password: password)
        }
    }

    private static func encrypt(url: URL, password: String) throws {
        guard let document = PDFDocument(url: url) else { throw Failure.writeFailed }
        let encryptedURL = url.deletingLastPathComponent().appendingPathComponent("encrypted-\(UUID().uuidString).pdf")
        let written = document.write(to: encryptedURL, withOptions: [
            .userPasswordOption: password,
            .ownerPasswordOption: password,
        ])
        guard written else { throw Failure.writeFailed }
        _ = try FileManager.default.replaceItemAt(url, withItemAt: encryptedURL)
    }

    /// Page size in points for an image, honoring the paper setting and orientation.
    static func pageSize(for imageSize: CGSize, paper: PaperSize) -> CGSize {
        let isLandscape = imageSize.width > imageSize.height
        guard let portrait = paper.portraitSize else {
            // Fit to image: keep US Letter width (or height for landscape) and follow the aspect ratio.
            guard imageSize.width > 0, imageSize.height > 0 else { return CGSize(width: 612, height: 792) }
            if isLandscape {
                return CGSize(width: 792, height: (792 * imageSize.height / imageSize.width).rounded())
            }
            return CGSize(width: 612, height: (612 * imageSize.height / imageSize.width).rounded())
        }
        return isLandscape ? CGSize(width: portrait.height, height: portrait.width) : portrait
    }

    static func aspectFitRect(for size: CGSize, in bounds: CGRect) -> CGRect {
        guard size.width > 0, size.height > 0 else { return bounds }
        let scale = min(bounds.width / size.width, bounds.height / size.height)
        let fitted = CGSize(width: size.width * scale, height: size.height * scale)
        return CGRect(
            x: bounds.midX - fitted.width / 2,
            y: bounds.midY - fitted.height / 2,
            width: fitted.width,
            height: fitted.height
        )
    }

    /// Re-encodes the image at the target DPI so PDFs stay small.
    /// Quartz embeds JPEG-backed images without recompressing them.
    private static func downsampledJPEG(_ image: UIImage, for pointSize: CGSize, quality: ExportQuality) -> UIImage? {
        let scale = quality.dotsPerInch / 72
        let target = CGSize(width: pointSize.width * scale, height: pointSize.height * scale)
        let pixelSize = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
        let resized: UIImage
        if pixelSize.width > target.width * 1.05 {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = true
            let size = CGSize(width: target.width.rounded(), height: (target.width * pixelSize.height / pixelSize.width).rounded())
            resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
                image.draw(in: CGRect(origin: .zero, size: size))
            }
        } else {
            resized = image
        }
        guard let data = resized.jpegData(compressionQuality: quality.jpegCompression) else { return nil }
        return UIImage(data: data)
    }

    /// Draws OCR lines with the invisible text rendering mode, stretched over their boxes,
    /// so the text can be searched, selected and copied in any PDF reader.
    private static func drawInvisibleText(_ lines: [RecognizedLine], in imageRect: CGRect, context: CGContext) {
        for line in lines {
            let rect = CGRect(
                x: imageRect.minX + line.box.minX * imageRect.width,
                y: imageRect.minY + line.box.minY * imageRect.height,
                width: line.box.width * imageRect.width,
                height: line.box.height * imageRect.height
            )
            guard rect.width > 1, rect.height > 1 else { continue }

            let fontSize = rect.height * 0.9
            let font = CTFontCreateWithName("Helvetica" as CFString, fontSize, nil)
            let attributed = NSAttributedString(string: line.text, attributes: [
                NSAttributedString.Key(kCTFontAttributeName as String): font,
            ])
            let ctLine = CTLineCreateWithAttributedString(attributed)
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            let width = CGFloat(CTLineGetTypographicBounds(ctLine, &ascent, &descent, &leading))
            guard width > 0 else { continue }

            context.saveGState()
            context.textMatrix = .identity
            // UIKit PDF contexts are flipped; flip back locally so glyphs are upright.
            context.translateBy(x: rect.minX, y: rect.maxY - descent)
            context.scaleBy(x: rect.width / width, y: -1)
            context.setTextDrawingMode(.invisible)
            context.textPosition = .zero
            CTLineDraw(ctLine, context)
            context.restoreGState()
        }
    }

    private static func drawWatermark(in pageRect: CGRect) {
        let text = String(localized: "Scanned with Scanlet") as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8, weight: .medium),
            .foregroundColor: UIColor(white: 0.45, alpha: 0.85),
        ]
        let size = text.size(withAttributes: attributes)
        let origin = CGPoint(x: pageRect.maxX - size.width - 10, y: pageRect.maxY - size.height - 6)
        let background = CGRect(origin: origin, size: size).insetBy(dx: -4, dy: -2)
        UIColor(white: 1, alpha: 0.75).setFill()
        UIBezierPath(roundedRect: background, cornerRadius: 3).fill()
        text.draw(at: origin, withAttributes: attributes)
    }

    // MARK: - Images

    private static func writeImages(pages: [PageSnapshot], baseName: String, folder: URL, options: ExportOptions) throws -> [URL] {
        var urls: [URL] = []
        for (offset, page) in pages.enumerated() {
            try autoreleasepool {
                let name = pages.count == 1 ? baseName : "\(baseName) \(offset + 1)"
                let url = folder.appendingPathComponent(name).appendingPathExtension("jpg")
                var data = page.imageData
                if options.addWatermark, let image = UIImage(data: data) {
                    data = watermarked(image).jpegData(compressionQuality: options.quality.jpegCompression) ?? data
                } else if let image = UIImage(data: data), options.quality != .best {
                    data = image.jpegData(compressionQuality: options.quality.jpegCompression) ?? data
                }
                try data.write(to: url, options: .atomic)
                urls.append(url)
            }
        }
        return urls
    }

    private static func watermarked(_ image: UIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let size = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
            let text = String(localized: "Scanned with Scanlet") as NSString
            let fontSize = max(12, size.width * 0.018)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .medium),
                .foregroundColor: UIColor(white: 0.4, alpha: 0.85),
            ]
            let textSize = text.size(withAttributes: attributes)
            text.draw(at: CGPoint(x: size.width - textSize.width - fontSize, y: size.height - textSize.height - fontSize * 0.6), withAttributes: attributes)
        }
    }

    // MARK: - Files

    private static func makeExportFolder() throws -> URL {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("Exports", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }

    static func sanitizedFileName(_ title: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\?%*|\"<>:").union(.newlines).union(.controlCharacters)
        let cleaned = title.components(separatedBy: invalid).joined(separator: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let limited = String(cleaned.prefix(120))
        return limited.isEmpty ? String(localized: "Scan") : limited
    }
}
