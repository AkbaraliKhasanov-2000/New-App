import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Vision

/// Image pipeline for scanned pages: normalization, filters, rotation,
/// perspective correction and document edge detection.
///
/// All functions are synchronous and thread-safe; call them off the main actor.
enum ImageProcessor {
    /// Longest edge, in pixels, of stored pages. Enough for 300 dpi A4 while keeping memory in check.
    static let maxPixelDimension: CGFloat = 3508

    private static let context = CIContext(options: [.useSoftwareRenderer: false, .cacheIntermediates: false])

    // MARK: - Normalization

    /// Applies EXIF orientation, converts to sRGB and limits the size.
    static func normalized(_ image: UIImage) -> UIImage {
        let size = image.size
        let longest = max(size.width * image.scale, size.height * image.scale)
        let factor = longest > maxPixelDimension ? maxPixelDimension / longest : 1
        let targetSize = CGSize(
            width: (size.width * image.scale * factor).rounded(),
            height: (size.height * image.scale * factor).rounded()
        )
        if image.imageOrientation == .up, factor == 1, image.scale == 1, image.cgImage != nil {
            return image
        }
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    static func jpegData(_ image: UIImage, quality: CGFloat = 0.9) -> Data {
        image.jpegData(compressionQuality: quality) ?? Data()
    }

    // MARK: - Filters

    static func apply(_ filter: PageFilter, to image: UIImage) -> UIImage {
        guard filter != .original, let input = ciImage(from: image) else { return image }

        let output: CIImage
        switch filter {
        case .original:
            output = input
        case .enhanced:
            output = enhance(input)
        case .vivid:
            let vibrance = CIFilter.vibrance()
            vibrance.inputImage = enhance(input)
            vibrance.amount = 0.7
            output = vibrance.outputImage ?? input
        case .grayscale:
            let controls = CIFilter.colorControls()
            controls.inputImage = enhance(input)
            controls.saturation = 0
            controls.contrast = 1.1
            output = controls.outputImage ?? input
        case .blackAndWhite:
            output = blackAndWhite(input)
        }
        return render(output, extent: input.extent) ?? image
    }

    /// Shadow removal + contrast boost. Uses the system document enhancer when
    /// available and falls back to a tuned color/sharpen chain.
    private static func enhance(_ input: CIImage) -> CIImage {
        if let documentEnhancer = CIFilter(name: "CIDocumentEnhancer") {
            documentEnhancer.setValue(input, forKey: kCIInputImageKey)
            documentEnhancer.setValue(0.9, forKey: "inputAmount")
            if let output = documentEnhancer.outputImage {
                return sharpen(output, amount: 0.35)
            }
        }
        let controls = CIFilter.colorControls()
        controls.inputImage = input
        controls.contrast = 1.18
        controls.brightness = 0.03
        controls.saturation = 1.08
        let exposure = CIFilter.exposureAdjust()
        exposure.inputImage = controls.outputImage
        exposure.ev = 0.25
        return sharpen(exposure.outputImage ?? input, amount: 0.45)
    }

    private static func blackAndWhite(_ input: CIImage) -> CIImage {
        let controls = CIFilter.colorControls()
        controls.inputImage = enhance(input)
        controls.saturation = 0
        controls.contrast = 1.9
        controls.brightness = 0.12
        return sharpen(controls.outputImage ?? input, amount: 0.6)
    }

    private static func sharpen(_ input: CIImage, amount: Float) -> CIImage {
        let sharpen = CIFilter.sharpenLuminance()
        sharpen.inputImage = input
        sharpen.sharpness = amount
        sharpen.radius = 1.6
        return sharpen.outputImage ?? input
    }

    // MARK: - Geometry

    /// Rotates the image by 90° steps. Positive values rotate clockwise.
    static func rotated(_ image: UIImage, quarterTurns: Int) -> UIImage {
        let turns = ((quarterTurns % 4) + 4) % 4
        guard turns != 0 else { return image }
        let source = normalized(image)
        let swapsAxes = turns % 2 == 1
        let size = swapsAxes
            ? CGSize(width: source.size.height, height: source.size.width)
            : source.size
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
            let cg = rendererContext.cgContext
            cg.translateBy(x: size.width / 2, y: size.height / 2)
            cg.rotate(by: CGFloat(turns) * .pi / 2)
            source.draw(in: CGRect(
                x: -source.size.width / 2,
                y: -source.size.height / 2,
                width: source.size.width,
                height: source.size.height
            ))
        }
    }

    /// Crops and flattens a quadrilateral. Corners are normalized (0…1) with a top-left origin.
    static func perspectiveCorrected(_ image: UIImage, corners: Quadrilateral) -> UIImage {
        guard let input = ciImage(from: normalized(image)) else { return image }
        let width = input.extent.width
        let height = input.extent.height
        // Core Image uses a bottom-left origin.
        func point(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x * width, y: (1 - p.y) * height) }

        let filter = CIFilter.perspectiveCorrection()
        filter.inputImage = input
        filter.topLeft = point(corners.topLeft)
        filter.topRight = point(corners.topRight)
        filter.bottomLeft = point(corners.bottomLeft)
        filter.bottomRight = point(corners.bottomRight)
        guard let output = filter.outputImage else { return image }
        return render(output, extent: output.extent) ?? image
    }

    /// Finds the document outline in a photo, if any.
    static func detectDocument(in image: UIImage) -> Quadrilateral? {
        guard let cgImage = normalized(image).cgImage else { return nil }
        let request = VNDetectDocumentSegmentationRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        guard
            (try? handler.perform([request])) != nil,
            let observation = request.results?.first,
            observation.confidence > 0.6
        else { return nil }

        // Vision uses a bottom-left origin; convert to top-left.
        func flip(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x, y: 1 - p.y) }
        let quad = Quadrilateral(
            topLeft: flip(observation.topLeft),
            topRight: flip(observation.topRight),
            bottomRight: flip(observation.bottomRight),
            bottomLeft: flip(observation.bottomLeft)
        )
        // Ignore detections that are basically the full frame or too small to be useful.
        return quad.area > 0.12 && quad.area < 0.985 ? quad : nil
    }

    /// Normalizes an imported photo and flattens the document inside it when one is found.
    static func autoCropped(_ image: UIImage) -> UIImage {
        let base = normalized(image)
        guard let quad = detectDocument(in: base) else { return base }
        return perspectiveCorrected(base, corners: quad)
    }

    // MARK: - Composition

    /// Draws `overlay` (e.g. a signature) on top of `image` in a normalized rect (top-left origin).
    static func composite(_ overlay: UIImage, onto image: UIImage, normalizedRect: CGRect) -> UIImage {
        let base = normalized(image)
        let size = base.size
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            base.draw(at: .zero)
            let rect = CGRect(
                x: normalizedRect.minX * size.width,
                y: normalizedRect.minY * size.height,
                width: normalizedRect.width * size.width,
                height: normalizedRect.height * size.height
            )
            overlay.draw(in: rect, blendMode: .multiply, alpha: 1)
        }
    }

    /// Downscales an image to fit `maxDimension` for thumbnails and previews.
    static func thumbnail(from data: Data, maxPixelSize: CGFloat) -> UIImage? {
        let options: [CFString: Any] = [kCGImageSourceShouldCache: false]
        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else { return nil }
        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    // MARK: - Helpers

    private static func ciImage(from image: UIImage) -> CIImage? {
        if let cgImage = normalized(image).cgImage {
            return CIImage(cgImage: cgImage)
        }
        return image.ciImage
    }

    private static func render(_ image: CIImage, extent: CGRect) -> UIImage? {
        guard let cgImage = context.createCGImage(image, from: extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

/// Four corners of a document, normalized to 0…1 with a top-left origin.
struct Quadrilateral: Equatable, Sendable {
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint

    static let fullFrame = Quadrilateral(
        topLeft: CGPoint(x: 0, y: 0),
        topRight: CGPoint(x: 1, y: 0),
        bottomRight: CGPoint(x: 1, y: 1),
        bottomLeft: CGPoint(x: 0, y: 1)
    )

    static let inset = Quadrilateral(
        topLeft: CGPoint(x: 0.06, y: 0.06),
        topRight: CGPoint(x: 0.94, y: 0.06),
        bottomRight: CGPoint(x: 0.94, y: 0.94),
        bottomLeft: CGPoint(x: 0.06, y: 0.94)
    )

    var corners: [CGPoint] { [topLeft, topRight, bottomRight, bottomLeft] }

    /// Polygon area (shoelace formula), in normalized units.
    var area: CGFloat {
        let points = corners
        var sum: CGFloat = 0
        for index in points.indices {
            let current = points[index]
            let next = points[(index + 1) % points.count]
            sum += current.x * next.y - next.x * current.y
        }
        return abs(sum) / 2
    }
}
