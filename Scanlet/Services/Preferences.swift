import Foundation

/// UserDefaults keys shared by `@AppStorage` and non-view code.
enum PreferenceKey {
    static let defaultFilter = "defaultFilter"
    static let autoRecognizeText = "autoRecognizeText"
    static let recognitionLanguages = "recognitionLanguages"
    static let autoCropImports = "autoCropImports"
    static let paperSize = "paperSize"
    static let exportQuality = "exportQuality"
    static let appLockEnabled = "appLockEnabled"
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let libraryViewMode = "libraryViewMode"
    static let librarySort = "librarySort"
    static let freeTextExtractionsUsed = "freeTextExtractionsUsed"
    static let completedExports = "completedExports"
    static let lastReviewRequestVersion = "lastReviewRequestVersion"
}

/// Typed access to user preferences outside of SwiftUI views.
enum Preferences {
    private static var defaults: UserDefaults { .standard }

    static func registerDefaults() {
        defaults.register(defaults: [
            PreferenceKey.defaultFilter: PageFilter.enhanced.rawValue,
            PreferenceKey.autoRecognizeText: true,
            PreferenceKey.recognitionLanguages: "",
            PreferenceKey.autoCropImports: true,
            PreferenceKey.paperSize: PaperSize.automatic.rawValue,
            PreferenceKey.exportQuality: ExportQuality.balanced.rawValue,
            PreferenceKey.appLockEnabled: false,
            PreferenceKey.hasCompletedOnboarding: false,
            PreferenceKey.libraryViewMode: LibraryViewMode.grid.rawValue,
            PreferenceKey.librarySort: LibrarySort.dateModified.rawValue,
        ])
    }

    static var defaultFilter: PageFilter {
        PageFilter(rawValue: defaults.string(forKey: PreferenceKey.defaultFilter) ?? "") ?? .enhanced
    }

    static var autoRecognizeText: Bool {
        defaults.bool(forKey: PreferenceKey.autoRecognizeText)
    }

    static var autoCropImports: Bool {
        defaults.bool(forKey: PreferenceKey.autoCropImports)
    }

    /// Empty means "detect automatically".
    static var recognitionLanguages: [String] {
        let stored = defaults.string(forKey: PreferenceKey.recognitionLanguages) ?? ""
        return stored.split(separator: ",").map(String.init).filter { !$0.isEmpty }
    }

    static var paperSize: PaperSize {
        PaperSize(rawValue: defaults.string(forKey: PreferenceKey.paperSize) ?? "") ?? .automatic
    }

    static var exportQuality: ExportQuality {
        ExportQuality(rawValue: defaults.string(forKey: PreferenceKey.exportQuality) ?? "") ?? .balanced
    }
}

enum LibraryViewMode: String, CaseIterable, Identifiable {
    case grid
    case list

    var id: String { rawValue }
}

enum LibrarySort: String, CaseIterable, Identifiable {
    case dateModified
    case dateCreated
    case name

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dateModified: String(localized: "Date Modified")
        case .dateCreated: String(localized: "Date Created")
        case .name: String(localized: "Name")
        }
    }
}
