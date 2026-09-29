import CoreGraphics
import Foundation
import ImageIO
import Vision

/// One line of recognized text with its bounding box.
///
/// `box` is normalized to 0…1 with a **top-left** origin, so it can be mapped
/// directly onto UIKit and PDF drawing coordinates.
struct RecognizedLine: Codable, Hashable, Sendable {
    var text: String
    var box: CGRect
    var confidence: Float
}

struct RecognitionResult: Sendable {
    var lines: [RecognizedLine]
    var text: String
}

/// On-device text recognition (OCR) powered by the Vision framework.
/// Nothing ever leaves the device.
enum TextRecognizer {
    enum Failure: Error {
        case unreadableImage
    }

    /// Recognizes text in an encoded image (JPEG/PNG/HEIC).
    static func recognize(imageData: Data, languages: [String]) async throws -> RecognitionResult {
        try await Task.detached(priority: .utility) {
            guard
                let source = CGImageSourceCreateWithData(imageData as CFData, nil),
                let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
            else { throw Failure.unreadableImage }
            return try recognizeSynchronously(cgImage: cgImage, languages: languages)
        }.value
    }

    /// Languages Vision can read on this device, in the system's order.
    static func supportedLanguages() -> [String] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        return (try? request.supportedRecognitionLanguages()) ?? ["en-US"]
    }

    private static func recognizeSynchronously(cgImage: CGImage, languages: [String]) throws -> RecognitionResult {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.automaticallyDetectsLanguage = languages.isEmpty
        if !languages.isEmpty {
            request.recognitionLanguages = languages
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        let observations = request.results ?? []
        let lines: [RecognizedLine] = observations.compactMap { observation in
            guard let candidate = observation.topCandidates(1).first else { return nil }
            let text = candidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }
            let box = observation.boundingBox
            let topLeftBox = CGRect(x: box.minX, y: 1 - box.maxY, width: box.width, height: box.height)
            return RecognizedLine(text: text, box: topLeftBox, confidence: candidate.confidence)
        }
        return RecognitionResult(lines: lines, text: composeText(from: lines))
    }

    /// Joins lines in reading order and inserts blank lines between paragraphs.
    static func composeText(from lines: [RecognizedLine]) -> String {
        guard !lines.isEmpty else { return "" }
        let sorted = lines.sorted { lhs, rhs in
            // Same visual row when the vertical centers are close; then left-to-right.
            let rowTolerance = min(lhs.box.height, rhs.box.height) * 0.5
            if abs(lhs.box.midY - rhs.box.midY) < rowTolerance {
                return lhs.box.minX < rhs.box.minX
            }
            return lhs.box.minY < rhs.box.minY
        }

        var output = ""
        var previous: RecognizedLine?
        for line in sorted {
            if let previous {
                let sameRow = abs(previous.box.midY - line.box.midY) < min(previous.box.height, line.box.height) * 0.5
                if sameRow {
                    output += "  "
                } else {
                    let gap = line.box.minY - previous.box.maxY
                    output += gap > max(previous.box.height, line.box.height) * 1.2 ? "\n\n" : "\n"
                }
            }
            output += line.text
            previous = line
        }
        return output
    }
}
