import SwiftUI

/// Visual treatment applied to a captured page.
enum PageFilter: String, CaseIterable, Identifiable, Codable, Sendable {
    case original
    case enhanced
    case vivid
    case grayscale
    case blackAndWhite

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .original: "Original"
        case .enhanced: "Auto"
        case .vivid: "Vivid"
        case .grayscale: "Grayscale"
        case .blackAndWhite: "B&W"
        }
    }

    var accessibilityLabel: Text {
        switch self {
        case .original: Text("Original colors")
        case .enhanced: Text("Automatic enhancement")
        case .vivid: Text("Vivid colors")
        case .grayscale: Text("Grayscale")
        case .blackAndWhite: Text("Black and white")
        }
    }
}

/// Paper size used when laying out pages in an exported PDF.
enum PaperSize: String, CaseIterable, Identifiable, Sendable {
    case automatic
    case a4
    case letter
    case legal

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .automatic: "Fit to Image"
        case .a4: "A4"
        case .letter: "US Letter"
        case .legal: "US Legal"
        }
    }

    /// Portrait size in PostScript points, or `nil` to follow the image aspect ratio.
    var portraitSize: CGSize? {
        switch self {
        case .automatic: nil
        case .a4: CGSize(width: 595.28, height: 841.89)
        case .letter: CGSize(width: 612, height: 792)
        case .legal: CGSize(width: 612, height: 1008)
        }
    }
}

/// Image quality used when exporting.
enum ExportQuality: String, CaseIterable, Identifiable, Sendable {
    case small
    case balanced
    case best

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .small: "Small File"
        case .balanced: "Balanced"
        case .best: "Best Quality"
        }
    }

    /// Target resolution of embedded images.
    var dotsPerInch: CGFloat {
        switch self {
        case .small: 150
        case .balanced: 220
        case .best: 300
        }
    }

    var jpegCompression: CGFloat {
        switch self {
        case .small: 0.55
        case .balanced: 0.72
        case .best: 0.88
        }
    }
}

/// File format offered in the export sheet.
enum ExportFormat: String, CaseIterable, Identifiable, Sendable {
    case pdf
    case images
    case text

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .pdf: "PDF"
        case .images: "JPG"
        case .text: "Text"
        }
    }

    var systemImage: String {
        switch self {
        case .pdf: "doc.richtext"
        case .images: "photo.on.rectangle"
        case .text: "text.alignleft"
        }
    }
}
