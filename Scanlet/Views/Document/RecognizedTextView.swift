import SwiftData
import SwiftUI
#if canImport(Translation)
import Translation
#endif

/// Shows the on-device OCR result for a document with copy, share and translate actions.
struct RecognizedTextView: View {
    let document: ScanDocument

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionStore.self) private var store
    @Environment(AppRouter.self) private var router

    @State private var isRecognizing = false
    @State private var hasAccess = false
    @State private var didCopy = false
    @State private var isShowingTranslation = false

    var body: some View {
        NavigationStack {
            Group {
                if !hasAccess {
                    lockedState
                } else if isRecognizing {
                    VStack(spacing: 14) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Recognizing text…")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if fullText.isEmpty {
                    ContentUnavailableView {
                        Label("No Text Found", systemImage: "text.magnifyingglass")
                    } description: {
                        Text("Try a sharper scan with good lighting, or pick recognition languages in Settings.")
                    }
                } else {
                    textList
                }
            }
            .navigationTitle("Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .modifier(TranslationModifier(isPresented: $isShowingTranslation, text: fullText))
            .sensoryFeedback(.success, trigger: didCopy)
            .task { await prepare() }
        }
        .presentationDragIndicator(.visible)
    }

    private var textList: some View {
        List {
            ForEach(Array(document.orderedPages.enumerated()), id: \.element.id) { offset, page in
                if let text = page.recognizedText, !text.isEmpty {
                    Section {
                        Text(text)
                            .font(.body)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    } header: {
                        if document.pageCount > 1 {
                            Text("Page \(offset + 1)")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var lockedState: some View {
        ContentUnavailableView {
            Label("Free Text Recognitions Used", systemImage: "text.viewfinder")
        } description: {
            Text("Upgrade to Scanlet Pro for unlimited text recognition, searchable PDFs and more.")
        } actions: {
            Button("Unlock Scanlet Pro") {
                dismiss()
                Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    router.showPaywall(.textExtraction)
                }
            }
            .prominentActionStyle()
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Done") { dismiss() }
        }
        if hasAccess && !fullText.isEmpty {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    UIPasteboard.general.string = fullText
                    didCopy.toggle()
                } label: {
                    Label("Copy All", systemImage: "doc.on.doc")
                }
                Spacer()
                if TranslationModifier.isSupported {
                    Button {
                        isShowingTranslation = true
                    } label: {
                        Label("Translate", systemImage: "translate")
                    }
                    Spacer()
                }
                ShareLink(item: fullText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }

    private var fullText: String {
        document.orderedPages
            .compactMap(\.recognizedText)
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }

    private func prepare() async {
        guard !hasAccess else { return }
        hasAccess = store.consumeTextExtraction(for: document.id)
        guard hasAccess else { return }

        let pending = document.orderedPages.filter { $0.recognizedText == nil }
        guard !pending.isEmpty else { return }
        isRecognizing = true
        for page in pending {
            await TextIndexer.shared.recognize(page, context: modelContext)
        }
        isRecognizing = false
    }
}

/// Presents the system translation overlay on iOS 17.4 and later.
private struct TranslationModifier: ViewModifier {
    @Binding var isPresented: Bool
    let text: String

    static var isSupported: Bool {
        if #available(iOS 17.4, *) { return true }
        return false
    }

    func body(content: Content) -> some View {
        #if canImport(Translation)
        if #available(iOS 17.4, *) {
            content.translationPresentation(isPresented: $isPresented, text: text)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
