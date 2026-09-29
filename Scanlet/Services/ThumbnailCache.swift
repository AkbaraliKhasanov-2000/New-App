import UIKit

/// In-memory cache of decoded page thumbnails keyed by `ScanPage.cacheKey`.
final class ThumbnailCache: @unchecked Sendable {
    static let shared = ThumbnailCache()

    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 300
        cache.totalCostLimit = 120 * 1024 * 1024
        return cache
    }()

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func insert(_ image: UIImage, for key: String) {
        let cost = Int(image.size.width * image.size.height * image.scale * image.scale * 4)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }

    /// Decodes a downscaled image off the main thread, using the cache when possible.
    func thumbnail(key: String, data: Data?, maxPixelSize: CGFloat) async -> UIImage? {
        let cacheKey = "\(key)@\(Int(maxPixelSize))"
        if let cached = image(for: cacheKey) { return cached }
        guard let data else { return nil }
        let image = await Task.detached(priority: .userInitiated) {
            ImageProcessor.thumbnail(from: data, maxPixelSize: maxPixelSize)?.preparingForDisplay()
        }.value
        if let image { insert(image, for: cacheKey) }
        return image
    }
}
