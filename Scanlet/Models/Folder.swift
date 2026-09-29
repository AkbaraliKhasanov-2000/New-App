import Foundation
import SwiftData

/// A user-created folder that groups documents in the library.
@Model
final class Folder {
    var id: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \ScanDocument.folder)
    var documents: [ScanDocument] = []

    init(name: String) {
        self.name = name
    }
}
