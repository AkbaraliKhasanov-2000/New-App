import Foundation

/// Static configuration. Update the URLs and IDs before submitting to the App Store.
enum AppConfig {
    static let appName = "Scanlet"
    /// Numeric Apple ID from App Store Connect (used for "Rate" and "Share" links).
    static let appStoreID = "0000000000"
    static let supportEmail = "support@scanlet.app"

    static let privacyPolicyURL = URL(string: "https://akbaralikhasanov-2000.github.io/New-App/privacy.html")!
    static let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")!

    static var appStoreURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreID)")!
    }

    static var writeReviewURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review")!
    }

    static var versionString: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}
