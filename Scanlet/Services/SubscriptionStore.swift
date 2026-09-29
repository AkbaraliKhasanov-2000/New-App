import Foundation
import Observation
import StoreKit

/// StoreKit 2 subscription manager for Scanlet Pro (weekly and monthly plans).
@MainActor
@Observable
final class SubscriptionStore {
    enum ProductID {
        static let weekly = "com.scanlet.app.pro.weekly"
        static let monthly = "com.scanlet.app.pro.monthly"
        static let all = [weekly, monthly]
    }

    enum PurchaseOutcome {
        case success
        case pending
        case cancelled
    }

    /// Free plan allowances.
    enum FreeLimits {
        static let textExtractions = 3
    }

    private(set) var products: [Product] = []
    private(set) var isPro = false
    private(set) var activeProductID: String?
    private(set) var isLoadingProducts = false
    private(set) var loadError: String?
    /// Products whose introductory offer (free trial) the user can still redeem.
    private(set) var trialEligibleProductIDs: Set<String> = []

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                await self?.refreshEntitlements()
            }
        }
        Task {
            await refreshEntitlements()
            await loadProducts()
        }
    }

    // MARK: - Products

    var weekly: Product? { products.first { $0.id == ProductID.weekly } }
    var monthly: Product? { products.first { $0.id == ProductID.monthly } }

    func loadProducts() async {
        guard products.isEmpty, !isLoadingProducts else { return }
        isLoadingProducts = true
        loadError = nil
        defer { isLoadingProducts = false }
        do {
            let loaded = try await Product.products(for: ProductID.all)
            products = loaded.sorted { $0.price < $1.price }
            var eligible: Set<String> = []
            for product in loaded {
                if let subscription = product.subscription,
                   subscription.introductoryOffer != nil,
                   await subscription.isEligibleForIntroOffer {
                    eligible.insert(product.id)
                }
            }
            trialEligibleProductIDs = eligible
            if loaded.isEmpty {
                loadError = String(localized: "Plans are unavailable right now. Check your connection and try again.")
            }
        } catch {
            loadError = String(localized: "Plans are unavailable right now. Check your connection and try again.")
        }
    }

    func retryLoadingProducts() async {
        products = []
        await loadProducts()
    }

    // MARK: - Purchasing

    func purchase(_ product: Product) async throws -> PurchaseOutcome {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                throw StoreError.failedVerification
            }
            await transaction.finish()
            await refreshEntitlements()
            return .success
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .cancelled
        }
    }

    /// Syncs purchases with the App Store (Restore Purchases).
    func restore() async throws {
        try await AppStore.sync()
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var activeID: String?
        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else { continue }
            guard ProductID.all.contains(transaction.productID), transaction.revocationDate == nil else { continue }
            if let expiration = transaction.expirationDate, expiration < .now { continue }
            activeID = transaction.productID
        }
        activeProductID = activeID
        isPro = activeID != nil
    }

    // MARK: - Pricing helpers

    func hasFreeTrial(_ product: Product) -> Bool {
        trialEligibleProductIDs.contains(product.id)
    }

    /// Human readable trial length, e.g. "3-day".
    func trialDescription(_ product: Product) -> String? {
        guard hasFreeTrial(product), let offer = product.subscription?.introductoryOffer else { return nil }
        return offer.period.localizedDuration
    }

    /// Percent saved by the monthly plan compared with paying weekly for a month.
    var monthlySavingsPercent: Int? {
        guard let weekly, let monthly else { return nil }
        let weeklyPerMonth = (weekly.price as NSDecimalNumber).doubleValue * 52 / 12
        let monthlyPrice = (monthly.price as NSDecimalNumber).doubleValue
        guard weeklyPerMonth > 0, monthlyPrice < weeklyPerMonth else { return nil }
        return Int(((1 - monthlyPrice / weeklyPerMonth) * 100).rounded(.down))
    }

    // MARK: - Free plan usage

    /// Documents whose text a free user has already unlocked (re-opening them is free).
    private var unlockedTextDocumentIDs: [String] {
        get { UserDefaults.standard.stringArray(forKey: PreferenceKey.freeTextExtractionsUsed) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: PreferenceKey.freeTextExtractionsUsed) }
    }

    var remainingFreeTextExtractions: Int {
        max(0, FreeLimits.textExtractions - unlockedTextDocumentIDs.count)
    }

    /// Returns true when the user may view the text of `documentID`, counting it against the free plan.
    func consumeTextExtraction(for documentID: UUID) -> Bool {
        if isPro { return true }
        let key = documentID.uuidString
        if unlockedTextDocumentIDs.contains(key) { return true }
        guard remainingFreeTextExtractions > 0 else { return false }
        unlockedTextDocumentIDs.append(key)
        return true
    }
}

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        String(localized: "The purchase couldn’t be verified. Please try again.")
    }
}

extension Product.SubscriptionPeriod {
    /// "3-day", "1-week", "1-month" …
    var localizedDuration: String {
        let unitName: String = switch unit {
        case .day: value == 1 ? String(localized: "day") : String(localized: "days")
        case .week: value == 1 ? String(localized: "week") : String(localized: "weeks")
        case .month: value == 1 ? String(localized: "month") : String(localized: "months")
        case .year: value == 1 ? String(localized: "year") : String(localized: "years")
        @unknown default: ""
        }
        return "\(value) \(unitName)"
    }

    /// "week", "month" … used in "$4.99 / week".
    var localizedUnit: String {
        switch unit {
        case .day: String(localized: "day")
        case .week: String(localized: "week")
        case .month: String(localized: "month")
        case .year: String(localized: "year")
        @unknown default: ""
        }
    }
}
