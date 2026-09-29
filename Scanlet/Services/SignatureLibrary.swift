import Foundation
import Observation
import UIKit

/// Saved signatures stored as transparent PNG files in Application Support.
@MainActor
@Observable
final class SignatureLibrary {
    struct Signature: Identifiable, Hashable {
        let id: String
        let url: URL
        let image: UIImage

        static func == (lhs: Signature, rhs: Signature) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    private(set) var signatures: [Signature] = []

    private let folder: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("Signatures", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }()

    init() {
        reload()
    }

    func reload() {
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )) ?? []
        signatures = urls
            .filter { $0.pathExtension == "png" }
            .sorted { lhs, rhs in
                let left = (try? lhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                let right = (try? rhs.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
                return left > right
            }
            .compactMap { url in
                guard let image = UIImage(contentsOfFile: url.path) else { return nil }
                return Signature(id: url.lastPathComponent, url: url, image: image)
            }
    }

    @discardableResult
    func save(_ image: UIImage) -> Signature? {
        guard let data = image.pngData() else { return nil }
        let url = folder.appendingPathComponent("\(UUID().uuidString).png")
        do {
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            return nil
        }
        reload()
        return signatures.first { $0.url == url }
    }

    func delete(_ signature: Signature) {
        try? FileManager.default.removeItem(at: signature.url)
        reload()
    }
}
