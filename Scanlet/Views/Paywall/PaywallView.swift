import StoreKit
import SwiftUI

struct PaywallView: View {
    let trigger: PaywallTrigger

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(SubscriptionStore.self) private var store

    @State private var selectedProductID: String = SubscriptionStore.ProductID.weekly
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var alert: PaywallAlert?
    @State private var purchaseFeedback = false
    @State private var animateHero = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    features
                        .padding(16)
                        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 20, style: .continuous))
                    plans
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(background)
            .safeAreaInset(edge: .bottom) { purchaseFooter }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                    .accessibilityLabel(Text("Close"))
                }
            }
            .alert(alert?.title ?? "", isPresented: alertBinding, presenting: alert) { _ in
                Button("OK", role: .cancel) {}
            } message: { alert in
                Text(alert.message)
            }
            .task {
                await store.loadProducts()
                if let weekly = store.weekly, store.hasFreeTrial(weekly) {
                    selectedProductID = weekly.id
                }
            }
            .onChange(of: store.isPro) { _, isPro in
                if isPro { dismiss() }
            }
            .sensoryFeedback(.success, trigger: purchaseFeedback)
            .sensoryFeedback(.selection, trigger: selectedProductID)
        }
        .interactiveDismissDisabled(isPurchasing)
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 68, height: 68)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 12, y: 6)
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: animateHero)
            }
            .accessibilityHidden(true)
            .onAppear { animateHero.toggle() }

            VStack(spacing: 6) {
                Text(trigger.headline)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Everything you need to scan, sign and share documents.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Features

    private var features: some View {
        VStack(alignment: .leading, spacing: 12) {
            FeatureRow(symbol: "text.viewfinder", color: .blue,
                       title: "Unlimited Text Recognition",
                       subtitle: "Copy, translate and share text from any page.")
            FeatureRow(symbol: "doc.text.magnifyingglass", color: .indigo,
                       title: "Searchable PDFs",
                       subtitle: "Find words inside your scans in any PDF app.")
            FeatureRow(symbol: "signature", color: .purple,
                       title: "Sign Documents",
                       subtitle: "Draw once, place your signature in seconds.")
            FeatureRow(symbol: "lock.doc", color: .orange,
                       title: "Password-Protected PDFs",
                       subtitle: "Share sensitive files safely.")
            FeatureRow(symbol: "faceid", color: .green,
                       title: "Face ID App Lock",
                       subtitle: "Keep your documents private.")
            FeatureRow(symbol: "sparkles", color: .pink,
                       title: "No Watermark",
                       subtitle: "Clean, professional exports.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Plans

    @ViewBuilder
    private var plans: some View {
        if store.products.isEmpty {
            VStack(spacing: 12) {
                if store.isLoadingProducts {
                    ProgressView()
                } else {
                    Text(store.loadError ?? String(localized: "Plans are unavailable right now."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Try Again") {
                        Task { await store.retryLoadingProducts() }
                    }
                    .secondaryActionStyle()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 140)
        } else {
            VStack(spacing: 12) {
                ForEach(orderedProducts, id: \.id) { product in
                    PlanCard(
                        product: product,
                        isSelected: product.id == selectedProductID,
                        badge: badge(for: product),
                        detail: detail(for: product)
                    ) {
                        withAnimation(.snappy) { selectedProductID = product.id }
                    }
                }
            }
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(get: { alert != nil }, set: { if !$0 { alert = nil } })
    }

    private var orderedProducts: [Product] {
        [store.weekly, store.monthly].compactMap { $0 }
    }

    private var selectedProduct: Product? {
        store.products.first { $0.id == selectedProductID }
    }

    private func badge(for product: Product) -> String? {
        if product.id == SubscriptionStore.ProductID.monthly, let percent = store.monthlySavingsPercent {
            return String(localized: "SAVE \(percent)%")
        }
        if store.hasFreeTrial(product), let trial = store.trialDescription(product) {
            return String(localized: "\(trial) free").uppercased()
        }
        return nil
    }

    private func detail(for product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else { return product.displayPrice }
        if store.hasFreeTrial(product), let trial = store.trialDescription(product) {
            return String(localized: "\(trial) free, then \(product.displayPrice)/\(period.localizedUnit)")
        }
        return String(localized: "\(product.displayPrice)/\(period.localizedUnit), cancel anytime")
    }

    // MARK: - Footer

    private var purchaseFooter: some View {
        VStack(spacing: 10) {
            Button {
                Task { await purchase() }
            } label: {
                Group {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text(ctaTitle)
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .prominentActionStyle()
            .controlSize(.large)
            .disabled(selectedProduct == nil || isPurchasing || isRestoring)

            if let selectedProduct {
                Text(renewalDisclosure(for: selectedProduct))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 18) {
                Button(isRestoring ? LocalizedStringKey("Restoring…") : LocalizedStringKey("Restore Purchases")) {
                    Task { await restore() }
                }
                .disabled(isRestoring || isPurchasing)
                Button("Terms of Use") { openURL(AppConfig.termsOfUseURL) }
                Button("Privacy Policy") { openURL(AppConfig.privacyPolicyURL) }
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background {
            Rectangle()
                .fill(.bar)
                .ignoresSafeArea()
                .mask(LinearGradient(colors: [.clear, .black, .black], startPoint: .top, endPoint: .bottom))
        }
    }

    private var ctaTitle: LocalizedStringKey {
        if let selectedProduct, store.hasFreeTrial(selectedProduct) {
            return "Start Free Trial"
        }
        return "Continue"
    }

    private func renewalDisclosure(for product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else { return "" }
        let price = "\(product.displayPrice)/\(period.localizedUnit)"
        if store.hasFreeTrial(product), let trial = store.trialDescription(product) {
            return String(localized: "Free for \(trial), then \(price). Renews automatically until canceled. Cancel anytime in Settings at least 24 hours before the trial ends.")
        }
        return String(localized: "\(price). Renews automatically until canceled. Cancel anytime in Settings at least 24 hours before the period ends.")
    }

    private var background: some View {
        LinearGradient(
            colors: [Color.accentColor.opacity(0.14), Color(.systemBackground), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Actions

    private func purchase() async {
        guard let selectedProduct else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            switch try await store.purchase(selectedProduct) {
            case .success:
                purchaseFeedback.toggle()
                dismiss()
            case .pending:
                alert = PaywallAlert(
                    title: String(localized: "Purchase Pending"),
                    message: String(localized: "Your purchase is waiting for approval. Scanlet Pro unlocks automatically once it’s approved.")
                )
            case .cancelled:
                break
            }
        } catch {
            alert = PaywallAlert(title: String(localized: "Purchase Failed"), message: error.localizedDescription)
        }
    }

    private func restore() async {
        isRestoring = true
        defer { isRestoring = false }
        do {
            try await store.restore()
            if store.isPro {
                purchaseFeedback.toggle()
                dismiss()
            } else {
                alert = PaywallAlert(
                    title: String(localized: "Nothing to Restore"),
                    message: String(localized: "No active Scanlet Pro subscription was found for this Apple Account.")
                )
            }
        } catch {
            alert = PaywallAlert(title: String(localized: "Restore Failed"), message: error.localizedDescription)
        }
    }
}

private struct PaywallAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

private struct FeatureRow: View {
    let symbol: String
    let color: Color
    let title: LocalizedStringKey
    /// Kept for VoiceOver; the visual list stays one line per feature so plans fit on the first screen.
    let subtitle: LocalizedStringKey

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(color.gradient, in: .rect(cornerRadius: 7, style: .continuous))
                .accessibilityHidden(true)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Spacer(minLength: 0)
            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(subtitle))
    }
}

private struct PlanCard: View {
    let product: Product
    let isSelected: Bool
    let badge: String?
    let detail: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(.headline)
                        if let badge {
                            Text(badge)
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.accentColor.gradient, in: .capsule)
                        }
                    }
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Text(product.displayPrice)
                    .font(.headline.monospacedDigit())
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(isSelected ? Color.accentColor : Color(.separator), lineWidth: isSelected ? 2.5 : 0.5)
            }
            .contentShape(.rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? AccessibilityTraits([.isSelected, .isButton]) : AccessibilityTraits.isButton)
    }
}
