import StoreKit
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @Environment(SubscriptionStore.self) private var store
    @Environment(AppLock.self) private var appLock
    @Environment(AppRouter.self) private var router

    @AppStorage(PreferenceKey.defaultFilter) private var defaultFilter: PageFilter = .enhanced
    @AppStorage(PreferenceKey.autoRecognizeText) private var autoRecognizeText = true
    @AppStorage(PreferenceKey.autoCropImports) private var autoCropImports = true
    @AppStorage(PreferenceKey.paperSize) private var paperSize: PaperSize = .automatic
    @AppStorage(PreferenceKey.exportQuality) private var exportQuality: ExportQuality = .balanced
    @AppStorage(PreferenceKey.appLockEnabled) private var appLockEnabled = false

    @State private var isShowingManageSubscriptions = false

    var body: some View {
        NavigationStack {
            Form {
                proSection

                Section {
                    Picker(selection: $defaultFilter) {
                        ForEach(PageFilter.allCases) { filter in
                            Text(filter.title).tag(filter)
                        }
                    } label: {
                        SettingsLabel("Default Filter", symbol: "camera.filters", color: .purple)
                    }
                    Toggle(isOn: $autoCropImports) {
                        SettingsLabel("Auto-Crop Imported Photos", symbol: "crop", color: .teal)
                    }
                } header: {
                    Text("Scanning")
                }

                Section {
                    Toggle(isOn: $autoRecognizeText) {
                        SettingsLabel("Recognize Text Automatically", symbol: "text.viewfinder", color: .blue)
                    }
                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        LabeledContent {
                            Text(languageSummary)
                        } label: {
                            SettingsLabel("Recognition Languages", symbol: "globe", color: .indigo)
                        }
                    }
                } header: {
                    Text("Text Recognition")
                } footer: {
                    Text("Text is recognized on your iPhone, so you can search inside your scans. Nothing is uploaded.")
                }

                Section("Export") {
                    Picker(selection: $paperSize) {
                        ForEach(PaperSize.allCases) { size in
                            Text(size.title).tag(size)
                        }
                    } label: {
                        SettingsLabel("Page Size", symbol: "doc", color: .orange)
                    }
                    Picker(selection: $exportQuality) {
                        ForEach(ExportQuality.allCases) { quality in
                            Text(quality.title).tag(quality)
                        }
                    } label: {
                        SettingsLabel("Quality", symbol: "dial.medium", color: .gray)
                    }
                }

                Section {
                    Toggle(isOn: appLockBinding) {
                        HStack {
                            SettingsLabel("Require \(AppLock.biometryName)", symbol: AppLock.biometrySymbol, color: .green)
                            if !store.isPro {
                                Spacer()
                                ProBadge()
                            }
                        }
                    }
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("Scanmuse stores your documents only on this iPhone.")
                }

                Section("Support") {
                    Button {
                        requestReview()
                    } label: {
                        SettingsLabel("Rate Scanmuse", symbol: "star", color: .yellow)
                    }
                    ShareLink(item: AppConfig.appStoreURL, message: Text("I scan documents with Scanmuse.")) {
                        SettingsLabel("Share Scanmuse", symbol: "square.and.arrow.up", color: .green)
                    }
                    Button {
                        if let url = supportMailURL { openURL(url) }
                    } label: {
                        SettingsLabel("Contact Support", symbol: "envelope", color: .blue)
                    }
                }

                Section {
                    Button {
                        openURL(AppConfig.privacyPolicyURL)
                    } label: {
                        SettingsLabel("Privacy Policy", symbol: "hand.raised", color: .gray)
                    }
                    Button {
                        openURL(AppConfig.termsOfUseURL)
                    } label: {
                        SettingsLabel("Terms of Use", symbol: "doc.text", color: .gray)
                    }
                    LabeledContent("Version", value: AppConfig.versionString)
                } header: {
                    Text("About")
                }
            }
            .tint(.accentColor)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .manageSubscriptionsSheet(isPresented: $isShowingManageSubscriptions)
        }
    }

    @ViewBuilder
    private var proSection: some View {
        Section {
            if store.isPro {
                HStack(spacing: 14) {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Scanmuse Pro")
                            .font(.headline)
                        Text("All features unlocked. Thank you!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Button("Manage Subscription") {
                    isShowingManageSubscriptions = true
                }
            } else {
                Button {
                    dismiss()
                    Task {
                        try? await Task.sleep(for: .milliseconds(400))
                        router.showPaywall(.settings)
                    }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "crown.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.orange.gradient, in: .rect(cornerRadius: 11, style: .continuous))
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Scanmuse Pro")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Unlimited OCR, signatures, no watermark")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.tertiary)
                            .accessibilityHidden(true)
                    }
                    .padding(.vertical, 4)
                    .contentShape(.rect)
                }
                // Keep the title/subtitle colors instead of the Form's button tint.
                .buttonStyle(.plain)
                Button("Restore Purchases") {
                    Task { try? await store.restore() }
                }
            }
        }
    }

    private var appLockBinding: Binding<Bool> {
        Binding(
            get: { appLockEnabled },
            set: { newValue in
                guard store.isPro || !newValue else {
                    dismiss()
                    Task {
                        try? await Task.sleep(for: .milliseconds(400))
                        router.showPaywall(.appLock)
                    }
                    return
                }
                Task {
                    if await appLock.setEnabled(newValue) {
                        appLockEnabled = newValue
                    }
                }
            }
        )
    }

    private var languageSummary: String {
        let languages = Preferences.recognitionLanguages
        if languages.isEmpty { return String(localized: "Automatic") }
        return languages
            .map { Locale.current.localizedString(forIdentifier: $0) ?? $0 }
            .formatted(.list(type: .and, width: .short))
    }

    private var supportMailURL: URL? {
        let subject = "Scanmuse \(AppConfig.versionString)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Scanmuse"
        return URL(string: "mailto:\(AppConfig.supportEmail)?subject=\(subject)")
    }
}

/// Lets the user pin recognition languages (defaults to automatic detection).
struct LanguageSettingsView: View {
    @AppStorage(PreferenceKey.recognitionLanguages) private var stored = ""
    @State private var available: [String] = []

    var body: some View {
        List {
            Section {
                Button {
                    stored = ""
                } label: {
                    HStack {
                        Text("Automatic")
                            .foregroundStyle(.primary)
                        Spacer()
                        if selected.isEmpty {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .accessibilityAddTraits(selected.isEmpty ? .isSelected : [])
            } footer: {
                Text("Automatic works for most documents. Choose specific languages to improve accuracy for mixed or uncommon text.")
            }

            Section("Languages") {
                ForEach(available, id: \.self) { code in
                    Button {
                        toggle(code)
                    } label: {
                        HStack {
                            Text(Locale.current.localizedString(forIdentifier: code) ?? code)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selected.contains(code) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .accessibilityAddTraits(selected.contains(code) ? .isSelected : [])
                }
            }
        }
        .navigationTitle("Languages")
        .navigationBarTitleDisplayMode(.inline)
        .task { available = TextRecognizer.supportedLanguages() }
    }

    private var selected: [String] {
        stored.split(separator: ",").map(String.init)
    }

    private func toggle(_ code: String) {
        var current = selected
        if let index = current.firstIndex(of: code) {
            current.remove(at: index)
        } else {
            current.append(code)
        }
        stored = current.joined(separator: ",")
    }
}

/// Settings row label with a colored icon tile, like the iOS Settings app.
struct SettingsLabel: View {
    let title: LocalizedStringKey
    let symbol: String
    let color: Color

    init(_ title: LocalizedStringKey, symbol: String, color: Color) {
        self.title = title
        self.symbol = symbol
        self.color = color
    }

    var body: some View {
        Label {
            Text(title)
                .foregroundStyle(.primary)
        } icon: {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 29, height: 29)
                .background(color.gradient, in: .rect(cornerRadius: 7, style: .continuous))
        }
    }
}
