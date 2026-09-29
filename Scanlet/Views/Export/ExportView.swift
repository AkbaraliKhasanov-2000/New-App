import StoreKit
import SwiftData
import SwiftUI

/// Export options for one or more documents, followed by the system share sheet.
struct ExportView: View {
    let documents: [ScanDocument]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    @Environment(SubscriptionStore.self) private var store
    @Environment(AppRouter.self) private var router

    @AppStorage(PreferenceKey.paperSize) private var paperSize: PaperSize = .automatic
    @AppStorage(PreferenceKey.exportQuality) private var quality: ExportQuality = .balanced
    @AppStorage(PreferenceKey.completedExports) private var completedExports = 0

    @State private var format: ExportFormat = .pdf
    @State private var includeTextLayer = true
    @State private var usePassword = false
    @State private var password = ""
    @State private var isExporting = false
    @State private var sharePayload: SharePayload?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                summarySection

                Section {
                    Picker("Format", selection: $format) {
                        ForEach(ExportFormat.allCases) { format in
                            Text(format.title).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }

                switch format {
                case .pdf: pdfSections
                case .images: imageSections
                case .text: textSection
                }

                if !store.isPro && format != .text {
                    Section {
                        Button {
                            showPaywall(.export)
                        } label: {
                            HStack {
                                Label("Remove “Scanned with Scanlet”", systemImage: "wand.and.stars")
                                Spacer()
                                ProBadge()
                            }
                        }
                    } footer: {
                        Text("Free exports include a small footer.")
                    }
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task { await export() }
                } label: {
                    Group {
                        if isExporting {
                            ProgressView()
                        } else {
                            Label("Export \(Text(format.title))", systemImage: "square.and.arrow.up")
                        }
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .prominentActionStyle()
                .controlSize(.large)
                .disabled(isExporting || (usePassword && password.isEmpty && format == .pdf))
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
            .sheet(item: $sharePayload) { payload in
                ShareSheet(items: payload.items) { completed in
                    sharePayload = nil
                    if completed { didCompleteExport() }
                }
                .ignoresSafeArea()
                .presentationDetents([.medium, .large])
            }
            .alert("Export Failed", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .onChange(of: store.isPro) { _, isPro in
                if isPro { includeTextLayer = true }
            }
        }
    }

    // MARK: - Sections

    private var summarySection: some View {
        Section {
            HStack(spacing: 14) {
                PaperThumbnail(page: documents.first?.coverPage, maxPixelSize: 200, cornerRadius: 6)
                    .frame(width: 44, height: 58)
                VStack(alignment: .leading, spacing: 2) {
                    Text(documents.count == 1 ? documents[0].title : String(localized: "\(documents.count) documents"))
                        .font(.headline)
                        .lineLimit(2)
                    Text("\(totalPages) pages")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
        }
    }

    @ViewBuilder
    private var pdfSections: some View {
        Section("Layout") {
            Picker("Page Size", selection: $paperSize) {
                ForEach(PaperSize.allCases) { size in
                    Text(size.title).tag(size)
                }
            }
            Picker("Quality", selection: $quality) {
                ForEach(ExportQuality.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
        }

        Section {
            proToggle(
                isOn: $includeTextLayer,
                trigger: .searchablePDF
            ) {
                Label("Searchable Text (OCR)", systemImage: "text.magnifyingglass")
            }
            proToggle(isOn: $usePassword, trigger: .password) {
                Label("Password Protection", systemImage: "lock")
            }
            if usePassword && store.isPro {
                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .submitLabel(.done)
            }
        } header: {
            Text("Options")
        } footer: {
            Text("Searchable PDFs let you find and copy text in any PDF app. Text is recognized on your iPhone.")
        }
    }

    private var imageSections: some View {
        Section {
            Picker("Quality", selection: $quality) {
                ForEach(ExportQuality.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
        } footer: {
            Text("Each page is exported as a separate JPG image.")
        }
    }

    private var textSection: some View {
        Section {
            Label("Exports the recognized text of every page as a plain text file.", systemImage: "text.alignleft")
                .foregroundStyle(.secondary)
        }
    }

    /// Toggle that opens the paywall instead of switching on for free users.
    private func proToggle<Content: View>(
        isOn: Binding<Bool>,
        trigger: PaywallTrigger,
        @ViewBuilder label: () -> Content
    ) -> some View {
        Toggle(isOn: Binding(
            get: { store.isPro && isOn.wrappedValue },
            set: { newValue in
                if store.isPro {
                    isOn.wrappedValue = newValue
                } else if newValue {
                    showPaywall(trigger)
                }
            }
        )) {
            HStack {
                label()
                if !store.isPro {
                    Spacer()
                    ProBadge()
                }
            }
        }
    }

    // MARK: - Actions

    private var totalPages: Int {
        documents.reduce(0) { $0 + $1.pageCount }
    }

    private var errorBinding: Binding<Bool> {
        Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
    }

    private func showPaywall(_ trigger: PaywallTrigger) {
        dismiss()
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            router.showPaywall(trigger)
        }
    }

    private func export() async {
        // Plain-text export is OCR output, so it shares the free text-recognition allowance.
        if format == .text && !store.isPro {
            let allowed = documents.allSatisfy { store.consumeTextExtraction(for: $0.id) }
            guard allowed else {
                showPaywall(.textExtraction)
                return
            }
        }

        isExporting = true
        defer { isExporting = false }

        // Text needs OCR results; recognize any missing pages first.
        if format == .text || (format == .pdf && includeTextLayer && store.isPro) {
            for document in documents {
                for page in document.orderedPages where page.recognizedText == nil {
                    await TextIndexer.shared.recognize(page, context: modelContext)
                }
            }
        }

        let options = ExportOptions(
            paperSize: paperSize,
            quality: quality,
            includeTextLayer: store.isPro && includeTextLayer,
            addWatermark: !store.isPro,
            password: store.isPro && usePassword ? password : nil
        )

        do {
            var urls: [URL] = []
            for document in documents {
                urls += try await DocumentExporter.export(
                    pages: document.orderedPages.map(\.snapshot),
                    title: document.title,
                    format: format,
                    options: options
                )
            }
            sharePayload = SharePayload(items: urls)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func didCompleteExport() {
        completedExports += 1
        // Ask for a rating after a few successful exports, at most once per version.
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let lastAsked = UserDefaults.standard.string(forKey: PreferenceKey.lastReviewRequestVersion)
        if completedExports >= 3, lastAsked != version {
            UserDefaults.standard.set(version, forKey: PreferenceKey.lastReviewRequestVersion)
            Task {
                try? await Task.sleep(for: .seconds(1))
                requestReview()
            }
        }
    }
}
