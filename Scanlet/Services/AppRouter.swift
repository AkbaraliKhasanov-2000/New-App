import Observation
import SwiftUI

/// App-wide navigation requests coming from App Intents, Spotlight and onboarding.
@MainActor
@Observable
final class AppRouter {
    static let shared = AppRouter()

    enum PendingAction: Equatable {
        case scan
        case importPhotos
    }

    var pendingAction: PendingAction?
    var isPaywallPresented = false
    var paywallTrigger: PaywallTrigger = .settings

    func showPaywall(_ trigger: PaywallTrigger) {
        paywallTrigger = trigger
        isPaywallPresented = true
    }
}

/// Why the paywall is being shown — drives its headline.
enum PaywallTrigger: Equatable {
    case onboarding
    case settings
    case export
    case textExtraction
    case signature
    case password
    case appLock
    case searchablePDF

    var headline: LocalizedStringKey {
        switch self {
        case .onboarding, .settings: "Unlock Scanlet Pro"
        case .export: "Export Without Watermark"
        case .textExtraction: "Unlimited Text Recognition"
        case .signature: "Sign Documents Instantly"
        case .password: "Protect PDFs with a Password"
        case .appLock: "Lock Scanlet with Face ID"
        case .searchablePDF: "Create Searchable PDFs"
        }
    }
}
