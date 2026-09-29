import PDFKit
import Testing
import UIKit
@testable import Scanlet

struct TextCompositionTests {
    @Test func joinsLinesInReadingOrder() {
        let lines = [
            RecognizedLine(text: "Second", box: CGRect(x: 0.1, y: 0.20, width: 0.3, height: 0.04), confidence: 1),
            RecognizedLine(text: "First", box: CGRect(x: 0.1, y: 0.10, width: 0.3, height: 0.04), confidence: 1),
        ]
        #expect(TextRecognizer.composeText(from: lines) == "First\n\nSecond")
    }

    @Test func keepsWordsOnTheSameRowTogether() {
        let lines = [
            RecognizedLine(text: "Total", box: CGRect(x: 0.1, y: 0.5, width: 0.2, height: 0.04), confidence: 1),
            RecognizedLine(text: "$12.00", box: CGRect(x: 0.7, y: 0.505, width: 0.2, height: 0.04), confidence: 1),
            RecognizedLine(text: "Thanks", box: CGRect(x: 0.1, y: 0.545, width: 0.2, height: 0.04), confidence: 1),
        ]
        #expect(TextRecognizer.composeText(from: lines) == "Total  $12.00\nThanks")
    }

    @Test func emptyInputProducesEmptyText() {
        #expect(TextRecognizer.composeText(from: []).isEmpty)
    }
}

struct LayoutTests {
    @Test func automaticPageSizeFollowsImageAspectRatio() {
        let size = DocumentExporter.pageSize(for: CGSize(width: 1000, height: 2000), paper: .automatic)
        #expect(size == CGSize(width: 612, height: 1224))
    }

    @Test func landscapeImagesRotateThePaper() {
        let size = DocumentExporter.pageSize(for: CGSize(width: 3000, height: 2000), paper: .a4)
        #expect(size.width > size.height)
    }

    @Test func aspectFitCentersContent() {
        let rect = DocumentExporter.aspectFitRect(for: CGSize(width: 100, height: 200), in: CGRect(x: 0, y: 0, width: 200, height: 200))
        #expect(rect == CGRect(x: 50, y: 0, width: 100, height: 200))
    }

    @Test func fileNamesAreSanitized() {
        #expect(DocumentExporter.sanitizedFileName("Tax/Return: 2026?") == "Tax-Return- 2026-")
        #expect(DocumentExporter.sanitizedFileName("   ").isEmpty == false)
    }

    @Test func quadrilateralArea() {
        #expect(Quadrilateral.fullFrame.area == 1)
        #expect(abs(Quadrilateral.inset.area - 0.7744) < 0.0001)
    }
}

struct ExportTests {
    private func sampleSnapshot() -> PageSnapshot {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: CGSize(width: 1240, height: 1754), format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1240, height: 1754))
        }
        let line = RecognizedLine(text: "Invoice 4471", box: CGRect(x: 0.1, y: 0.1, width: 0.4, height: 0.03), confidence: 1)
        return PageSnapshot(id: UUID(), imageData: image.jpegData(compressionQuality: 0.8)!, lines: [line], text: line.text)
    }

    @Test func searchablePDFContainsRecognizedText() async throws {
        let urls = try await DocumentExporter.export(
            pages: [sampleSnapshot()],
            title: "Test",
            format: .pdf,
            options: ExportOptions(includeTextLayer: true)
        )
        let document = try #require(PDFDocument(url: urls[0]))
        #expect(document.pageCount == 1)
        #expect(document.findString("Invoice", withOptions: .caseInsensitive).isEmpty == false)
    }

    @Test func passwordProtectedPDFIsLocked() async throws {
        let urls = try await DocumentExporter.export(
            pages: [sampleSnapshot()],
            title: "Secret",
            format: .pdf,
            options: ExportOptions(password: "1234")
        )
        let document = try #require(PDFDocument(url: urls[0]))
        #expect(document.isLocked)
        #expect(document.unlock(withPassword: "1234"))
    }

    @Test func textExportWritesPlainText() async throws {
        let urls = try await DocumentExporter.export(
            pages: [sampleSnapshot()],
            title: "Notes",
            format: .text,
            options: ExportOptions()
        )
        let text = try String(contentsOf: urls[0], encoding: .utf8)
        #expect(text == "Invoice 4471")
    }
}

struct ImageProcessorTests {
    @Test func rotationSwapsDimensions() {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 100), format: format).image { _ in }
        let rotated = ImageProcessor.rotated(image, quarterTurns: 1)
        #expect(rotated.size == CGSize(width: 100, height: 300))
    }

    @Test func everyFilterProducesAnImageOfTheSameSize() {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 600), format: format).image { context in
            UIColor.lightGray.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 600))
        }
        for filter in PageFilter.allCases {
            let output = ImageProcessor.apply(filter, to: image)
            #expect(output.size.width * output.scale == 400)
            #expect(output.size.height * output.scale == 600)
        }
    }
}
