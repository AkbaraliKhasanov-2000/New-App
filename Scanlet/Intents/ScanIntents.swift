import AppIntents

/// "Scan a document with Scanlet" — Siri, Spotlight, Shortcuts and the Action button.
struct ScanDocumentIntent: AppIntent {
    static let title: LocalizedStringResource = "Scan Document"
    static let description = IntentDescription("Opens Scanlet and starts scanning a document.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.pendingAction = .scan
        return .result()
    }
}

struct ImportPhotosIntent: AppIntent {
    static let title: LocalizedStringResource = "Import Photos to PDF"
    static let description = IntentDescription("Opens Scanlet and lets you turn photos into a PDF.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.pendingAction = .importPhotos
        return .result()
    }
}

struct ScanletShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ScanDocumentIntent(),
            phrases: [
                "Scan a document with \(.applicationName)",
                "Scan with \(.applicationName)",
                "Start a \(.applicationName) scan",
            ],
            shortTitle: "Scan Document",
            systemImageName: "doc.viewfinder"
        )
        AppShortcut(
            intent: ImportPhotosIntent(),
            phrases: [
                "Convert photos to PDF with \(.applicationName)",
                "Import photos into \(.applicationName)",
            ],
            shortTitle: "Photos to PDF",
            systemImageName: "photo.on.rectangle"
        )
    }
}
