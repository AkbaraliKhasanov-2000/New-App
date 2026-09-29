import SwiftData
import SwiftUI

@main
struct ScanletApp: App {
    @State private var store = SubscriptionStore()
    @State private var appLock = AppLock()
    @State private var signatures = SignatureLibrary()
    private let router = AppRouter.shared
    private let container: ModelContainer

    init() {
        Preferences.registerDefaults()
        do {
            let schema = Schema([ScanDocument.self, ScanPage.self, Folder.self])
            let configuration = ModelConfiguration("Scanlet", schema: schema)
            container = try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Unable to open the document database: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(appLock)
                .environment(signatures)
                .environment(router)
        }
        .modelContainer(container)
    }
}
