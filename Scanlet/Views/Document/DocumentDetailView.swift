import PhotosUI
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct DocumentDetailView: View {
    @Bindable var document: ScanDocument

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionStore.self) private var store
    @Environment(AppRouter.self) private var router

    @Query(sort: \Folder.name) private var folders: [Folder]

    @State private var editingPage: ScanPage?
    @State private var isShowingExport = false
    @State private var isShowingText = false
    @State private var isShowingSign = false
    @State private var isShowingOrganizer = false
    @State private var isShowingCamera = false
    @State private var isShowingPhotoPicker = false
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var isShowingFileImporter = false
    @State private var isProcessing = false
    @State private var isShowingDeleteConfirmation = false
    @State private var pageToDelete: ScanPage?
    @State private var addedPagesFeedback = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(Array(document.orderedPages.enumerated()), id: \.element.id) { offset, page in
                    PageCard(page: page, number: offset + 1, total: document.pageCount)
                        .onTapGesture { editingPage = page }
                        .contextMenu { pageMenu(for: page) }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAction(named: Text("Edit Page")) { editingPage = page }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle($document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .toolbar { toolbarContent }
        .safeAreaInset(edge: .bottom) { actionBar }
        .overlay {
            if isProcessing {
                ProcessingOverlay(title: "Processing pages…")
            } else if document.pages.isEmpty {
                ContentUnavailableView {
                    Label("No Pages", systemImage: "doc")
                } description: {
                    Text("Add pages by scanning or importing.")
                }
            }
        }
        .onChange(of: document.title) { _, _ in
            document.touch()
        }
        .fullScreenCover(item: $editingPage) { page in
            PageEditorView(page: page)
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            DocumentCamera { images in
                isShowingCamera = false
                Task { await addPages(images, autoCrop: false) }
            } onCancel: {
                isShowingCamera = false
            }
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $isShowingPhotoPicker, selection: $photoItems, maxSelectionCount: 50, matching: .images)
        .onChange(of: photoItems) { _, items in
            guard !items.isEmpty else { return }
            Task {
                var images: [UIImage] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                photoItems = []
                await addPages(images, autoCrop: Preferences.autoCropImports)
            }
        }
        .fileImporter(isPresented: $isShowingFileImporter, allowedContentTypes: [.pdf, .image], allowsMultipleSelection: true) { result in
            guard case .success(let urls) = result else { return }
            Task { await importFiles(urls) }
        }
        .sheet(isPresented: $isShowingExport) {
            ExportView(documents: [document])
        }
        .sheet(isPresented: $isShowingText) {
            RecognizedTextView(document: document)
        }
        .sheet(isPresented: $isShowingSign) {
            SignDocumentView(document: document)
        }
        .sheet(isPresented: $isShowingOrganizer) {
            PageOrganizerView(document: document)
        }
        .confirmationDialog("Delete Document?", isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                dismiss()
                let target = document
                Task {
                    try? await Task.sleep(for: .milliseconds(350))
                    DocumentService.delete([target], context: modelContext)
                }
            }
        } message: {
            Text("This can’t be undone.")
        }
        .confirmationDialog("Delete Page?", isPresented: pageDeleteBinding, titleVisibility: .visible) {
            Button("Delete Page", role: .destructive) {
                if let pageToDelete {
                    withAnimation { DocumentService.delete(pageToDelete, context: modelContext) }
                }
                pageToDelete = nil
            }
        }
        .sensoryFeedback(.success, trigger: addedPagesFeedback)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    document.isFavorite.toggle()
                } label: {
                    Label(document.isFavorite ? LocalizedStringKey("Remove from Favorites") : LocalizedStringKey("Add to Favorites"),
                          systemImage: document.isFavorite ? "star.slash" : "star")
                }
                Menu {
                    Button {
                        document.folder = nil
                    } label: {
                        Label("All Documents", systemImage: "tray.full")
                    }
                    ForEach(folders) { folder in
                        Button {
                            document.folder = folder
                        } label: {
                            if document.folder?.id == folder.id {
                                Label(folder.name, systemImage: "checkmark")
                            } else {
                                Text(folder.name)
                            }
                        }
                    }
                } label: {
                    Label("Move to Folder", systemImage: "folder")
                }
                Button {
                    isShowingOrganizer = true
                } label: {
                    Label("Organize Pages", systemImage: "square.grid.2x2")
                }
                .disabled(document.pages.isEmpty)
                Button {
                    _ = DocumentService.duplicate(document, context: modelContext)
                } label: {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                Divider()
                Button(role: .destructive) {
                    isShowingDeleteConfirmation = true
                } label: {
                    Label("Delete Document", systemImage: "trash")
                }
            } label: {
                Label("More", systemImage: "ellipsis")
            }
        }
    }

    // MARK: - Action bar

    /// Labeled actions: icons alone were ambiguous ("what does this button do?").
    private var actionBar: some View {
        HStack(spacing: 0) {
            Menu {
                Button {
                    if DocumentCamera.isAvailable { isShowingCamera = true } else { isShowingPhotoPicker = true }
                } label: {
                    Label("Scan Pages", systemImage: "doc.viewfinder")
                }
                Button {
                    isShowingPhotoPicker = true
                } label: {
                    Label("Import from Photos", systemImage: "photo.on.rectangle")
                }
                Button {
                    isShowingFileImporter = true
                } label: {
                    Label("Import from Files", systemImage: "folder")
                }
            } label: {
                ActionBarLabel(title: "Add Page", symbol: "plus.rectangle.on.rectangle")
            }

            ActionBarButton(title: "Text", symbol: "text.viewfinder") {
                isShowingText = true
            }
            .disabled(document.pages.isEmpty)

            ActionBarButton(title: "Sign", symbol: "signature") {
                if store.isPro {
                    isShowingSign = true
                } else {
                    router.showPaywall(.signature)
                }
            }
            .disabled(document.pages.isEmpty)

            ActionBarButton(title: "Share", symbol: "square.and.arrow.up", isProminent: true) {
                isShowingExport = true
            }
            .disabled(document.pages.isEmpty)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .glassSurface(cornerRadius: 30, interactive: true)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private func pageMenu(for page: ScanPage) -> some View {
        Button {
            editingPage = page
        } label: {
            Label("Edit Page", systemImage: "slider.horizontal.3")
        }
        Button {
            Task {
                isProcessing = true
                await DocumentService.rotate(page, clockwise: true, context: modelContext)
                isProcessing = false
            }
        } label: {
            Label("Rotate Right", systemImage: "rotate.right")
        }
        if let data = page.imageData, let image = UIImage(data: data) {
            ShareLink(
                item: Image(uiImage: image),
                preview: SharePreview(Text("Page \(page.index + 1)"), image: Image(uiImage: image))
            ) {
                Label("Share Page", systemImage: "square.and.arrow.up")
            }
        }
        Divider()
        Button(role: .destructive) {
            pageToDelete = page
        } label: {
            Label("Delete Page", systemImage: "trash")
        }
    }

    private var pageDeleteBinding: Binding<Bool> {
        Binding(get: { pageToDelete != nil }, set: { if !$0 { pageToDelete = nil } })
    }

    // MARK: - Adding pages

    private func addPages(_ images: [UIImage], autoCrop: Bool) async {
        guard !images.isEmpty else { return }
        isProcessing = true
        await DocumentService.addPages(images, to: document, folder: document.folder, autoCrop: autoCrop, context: modelContext)
        isProcessing = false
        addedPagesFeedback.toggle()
    }

    private func importFiles(_ urls: [URL]) async {
        isProcessing = true
        var pdfImages: [UIImage] = []
        var photos: [UIImage] = []
        for url in urls {
            if UTType(filenameExtension: url.pathExtension)?.conforms(to: .pdf) == true {
                pdfImages += await DocumentService.images(fromPDFAt: url)
            } else {
                let accessing = url.startAccessingSecurityScopedResource()
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    photos.append(image)
                }
                if accessing { url.stopAccessingSecurityScopedResource() }
            }
        }
        if !pdfImages.isEmpty {
            await DocumentService.addPages(pdfImages, to: document, folder: document.folder, autoCrop: false, context: modelContext)
        }
        if !photos.isEmpty {
            await DocumentService.addPages(photos, to: document, folder: document.folder, autoCrop: Preferences.autoCropImports, context: modelContext)
        }
        isProcessing = false
        addedPagesFeedback.toggle()
    }
}

/// A full-width page preview in the document reader.
private struct PageCard: View {
    let page: ScanPage
    let number: Int
    let total: Int

    var body: some View {
        VStack(spacing: 8) {
            PageImageView(page: page, maxPixelSize: 1400, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 6))
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(.separator, lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.1), radius: 10, y: 4)

            Text("\(number) of \(total)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Page \(number) of \(total)"))
        .accessibilityHint(Text("Double-tap to edit this page."))
    }
}

/// Icon above a short caption, used in the document action bar.
struct ActionBarLabel: View {
    let title: LocalizedStringKey
    let symbol: String
    var isProminent = false

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: symbol)
                .font(.system(size: 19, weight: .medium))
                .frame(height: 24)
            Text(title)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(isProminent ? Color.accentColor : Color.primary)
        .frame(maxWidth: .infinity, minHeight: 52)
        .contentShape(.rect)
    }
}

struct ActionBarButton: View {
    let title: LocalizedStringKey
    let symbol: String
    var isProminent = false
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            ActionBarLabel(title: title, symbol: symbol, isProminent: isProminent)
                .opacity(isEnabled ? 1 : 0.35)
        }
        .buttonStyle(.plain)
    }
}
