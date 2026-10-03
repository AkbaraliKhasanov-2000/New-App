import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(AppLock.self) private var appLock
    @Environment(AppRouter.self) private var router
    @Environment(SubscriptionStore.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(PreferenceKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(PreferenceKey.appLockEnabled) private var appLockEnabled = false
    @State private var showsPrivacyCover = false
    /// Auto-prompt only after returning from the background, never after a cancelled Face ID prompt.
    @State private var returnedFromBackground = false

    var body: some View {
        @Bindable var router = router

        LibraryView()
            .overlay {
                if appLock.isLocked {
                    LockScreenView()
                        .transition(.opacity)
                } else if showsPrivacyCover {
                    PrivacyCoverView()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: appLock.isLocked)
            .fullScreenCover(isPresented: onboardingBinding) {
                OnboardingView {
                    hasCompletedOnboarding = true
                    if !store.isPro {
                        // Give the cover time to dismiss before presenting the paywall.
                        Task {
                            try? await Task.sleep(for: .milliseconds(450))
                            router.showPaywall(.onboarding)
                        }
                    }
                }
            }
            .sheet(isPresented: $router.isPaywallPresented) {
                PaywallView(trigger: router.paywallTrigger)
            }
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .background:
                    appLock.lockIfNeeded()
                    returnedFromBackground = true
                case .inactive:
                    showsPrivacyCover = appLockEnabled
                case .active:
                    showsPrivacyCover = false
                    if returnedFromBackground {
                        returnedFromBackground = false
                        Task { await appLock.unlock() }
                        Task { await store.refreshEntitlements() }
                    }
                @unknown default:
                    break
                }
            }
            .task {
                DocumentExporter.purgeOldExports()
                await appLock.unlock()
                await TextIndexer.shared.indexPending(context: modelContext)
            }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !hasCompletedOnboarding },
            set: { hasCompletedOnboarding = !$0 }
        )
    }
}

/// Hides document contents in the app switcher when App Lock is on.
private struct PrivacyCoverView: View {
    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThickMaterial).ignoresSafeArea()
            Image(systemName: "doc.viewfinder.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.tint)
        }
        .accessibilityHidden(true)
    }
}

struct LockScreenView: View {
    @Environment(AppLock.self) private var appLock

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThickMaterial).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "lock.doc.fill")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.tint)
                    .symbolRenderingMode(.hierarchical)
                VStack(spacing: 6) {
                    Text("Scanlet Is Locked")
                        .font(.title2.bold())
                    Text("Your documents are protected.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                Button {
                    Task { await appLock.unlock() }
                } label: {
                    Label("Unlock with \(AppLock.biometryName)", systemImage: AppLock.biometrySymbol)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .prominentActionStyle()
                .controlSize(.large)
                .disabled(appLock.isAuthenticating)
            }
            .padding(32)
            .multilineTextAlignment(.center)
        }
    }
}
