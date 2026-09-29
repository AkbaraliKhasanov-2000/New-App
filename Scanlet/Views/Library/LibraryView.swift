import PhotosUI
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Which documents the library shows.
enum LibraryScope: Hashable {
    case all
    case favorites
    case folder(UUID)
}

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @Environment(SubscriptionStore.self) private var store

    @Query(sort: \ScanDocument.updatedAt, order: .reverse) private var documents: [ScanDocument]
    @Query(sort: \Folder.name) private var folders: [Folder]

    @AppStorage(PreferenceKey.libraryViewMode) private var viewMode: LibraryViewMode = .grid
    @AppStorage(PreferenceKey.librarySort) private var sort: LibrarySort = .dateModified

    @State private var path = NavigationPath()
    @State private var scope: LibraryScope = .all
    @State private var searchText = ""

    @State private var isSelecting = false
    @State private var selection: Set<UUID> = []

    @State private var isShowingCamera = false
    @State private var isShowingCameraUnavailable = false
    @State private var isShowingPhotoPicker = false
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var isShowingFileImporter = false
    @State private var isProcessing = false

    @State private var isShowingSettings = false
    @State private var exportTarget: ExportTarget?
    @State private var renameTarget: ScanDocument?
    @State private var renameText = ""
    @State private var isShowingNewFolder = false
    @State private var newFolderName = ""
    @State private var isShowingRenameFolder = false
    @State private var deleteTargets: [ScanDocument] = []
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingDeleteFolderConfirmation = false
    @State private var errorMessage: String?

    @State private var scanFeedback = false

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle(scopeTitle)
                .toolbarTitleMenu { scopeMenu }
                .searchable(text: $searchText, prompt: Text("Search titles and text"))
                .toolbar { toolbarContent }
                .safeAreaInset(edge: .bottom) {
                    if !isSelecting {
                        captureBar
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .navigationDestination(for: ScanDocument.self) { document in
                    DocumentDetailView(document: document)
                }
                .overlay {
                    if isProcessing {
                        ProcessingOverlay(title: "Processing pages…")
                    }
                }
                .animation(.snappy, value: isSelecting)
                .animation(.snappy, value: isProcessing)
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            DocumentCamera { images in
                isShowingCamera = false
                Task { await createDocument(from: images, autoCrop: false) }
            } onCancel: {
                isShowingCamera = false
            }
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $isShowingPhotoPicker, selection: $photoItems, maxSelectionCount: 50, matching: .images)
        .onChange(of: photoItems) { _, items in
            guard !items.isEmpty else { return }
            Task { await importPhotos(items) }
        }
        .fileImporter(isPresented: $isShowingFileImporter, allowedContentTypes: [.pdf, .image], allowsMultipleSelection: true) { result in
            Task { await importFiles(result) }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .sheet(item: $exportTarget) { target in
            ExportView(documents: target.documents)
        }
        .alert("Rename Document", isPresented: renameBinding) {
            TextField("Name", text: $renameText)
                .textInputAutocapitalization(.sentences)
            Button("Cancel", role: .cancel) {}
            Button("Save") { commitRename() }
        }
        .alert("New Folder", isPresented: $isShowingNewFolder) {
            TextField("Name", text: $newFolderName)
            Button("Cancel", role: .cancel) {}
            Button("Create") { createFolder() }
        } message: {
            Text("Enter a name for this folder.")
        }
        .alert("Rename Folder", isPresented: $isShowingRenameFolder) {
            TextField("Name", text: $newFolderName)
            Button("Cancel", role: .cancel) {}
            Button("Save") { renameCurrentFolder() }
        }
        .confirmationDialog(deleteTitle, isPresented: $isShowingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { confirmDelete() }
        } message: {
            Text("This can’t be undone.")
        }
        .confirmationDialog("Delete Folder?", isPresented: $isShowingDeleteFolderConfirmation, titleVisibility: .visible) {
            Button("Delete Folder", role: .destructive) { deleteCurrentFolder() }
        } message: {
            Text("Documents in this folder will be moved to All Documents.")
        }
        .alert("Camera Unavailable", isPresented: $isShowingCameraUnavailable) {
            Button("Import Photos") { isShowingPhotoPicker = true }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Document scanning isn’t supported on this device. You can import photos instead.")
        }
        .alert("Something Went Wrong", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .sensoryFeedback(.success, trigger: scanFeedback)
        .onChange(of: router.pendingAction) { _, action in
            handle(action)
        }
        .onAppear { handle(router.pendingAction) }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        let items = visibleDocuments
        if documents.isEmpty {
            ContentUnavailableView {
                Label("No Documents Yet", systemImage: "doc.viewfinder")
            } description: {
                Text("Scan paper documents, receipts and notes into sharp, searchable PDFs.")
            } actions: {
                Button("Scan Your First Document", action: startScan)
                    .prominentActionStyle()
            }
        } else if items.isEmpty {
            if searchText.isEmpty {
                ContentUnavailableView {
                    Label(scope == .favorites ? LocalizedStringKey("No Favorites") : LocalizedStringKey("Empty Folder"),
                          systemImage: scope == .favorites ? "star" : "folder")
                } description: {
                    Text(scope == .favorites
                         ? LocalizedStringKey("Mark documents as favorites to find them here.")
                         : LocalizedStringKey("Scan or move documents into this folder."))
                }
            } else {
                ContentUnavailableView.search(text: searchText)
            }
        } else {
            switch viewMode {
            case .grid: grid(items)
            case .list: list(items)
            }
        }
    }

    private func grid(_ items: [ScanDocument]) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 16)], spacing: 22) {
                ForEach(items) { document in
                    cell(for: document) {
                        DocumentGridCell(
                            document: document,
                            isSelecting: isSelecting,
                            isSelected: selection.contains(document.id)
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    private func list(_ items: [ScanDocument]) -> some View {
        List {
            ForEach(items) { document in
                cell(for: document) {
                    DocumentListRow(
                        document: document,
                        isSelecting: isSelecting,
                        isSelected: selection.contains(document.id)
                    )
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        requestDelete([document])
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        exportTarget = ExportTarget(documents: [document])
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .tint(.accentColor)
                }
                .swipeActions(edge: .leading) {
                    Button {
                        document.isFavorite.toggle()
                    } label: {
                        Label(document.isFavorite ? LocalizedStringKey("Unfavorite") : LocalizedStringKey("Favorite"),
                              systemImage: document.isFavorite ? "star.slash" : "star")
                    }
                    .tint(.yellow)
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func cell<CellLabel: View>(for document: ScanDocument, @ViewBuilder label: () -> CellLabel) -> some View {
        if isSelecting {
            Button {
                toggleSelection(document)
            } label: {
                label()
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(selection.contains(document.id) ? .isSelected : [])
        } else {
            NavigationLink(value: document) {
                label()
            }
            .buttonStyle(.plain)
            .contextMenu { contextMenu(for: document) }
        }
    }

    @ViewBuilder
    private func contextMenu(for document: ScanDocument) -> some View {
        Button {
            exportTarget = ExportTarget(documents: [document])
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        Button {
            renameText = document.title
            renameTarget = document
        } label: {
            Label("Rename", systemImage: "pencil")
        }
        Button {
            document.isFavorite.toggle()
        } label: {
            Label(document.isFavorite ? LocalizedStringKey("Remove from Favorites") : LocalizedStringKey("Add to Favorites"),
                  systemImage: document.isFavorite ? "star.slash" : "star")
        }
        moveMenu(for: [document])
        Button {
            _ = DocumentService.duplicate(document, context: modelContext)
        } label: {
            Label("Duplicate", systemImage: "plus.square.on.square")
        }
        Divider()
        Button(role: .destructive) {
            requestDelete([document])
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    @ViewBuilder
    private func moveMenu(for targets: [ScanDocument]) -> some View {
        Menu {
            Button {
                move(targets, to: nil)
            } label: {
                Label("All Documents", systemImage: "tray.full")
            }
            ForEach(folders) { folder in
                Button {
                    move(targets, to: folder)
                } label: {
                    Label(folder.name, systemImage: "folder")
                }
            }
            Divider()
            Button {
                pendingMoveTargets = targets
                newFolderName = ""
                isShowingNewFolder = true
            } label: {
                Label("New Folder…", systemImage: "folder.badge.plus")
            }
        } label: {
            Label("Move to Folder", systemImage: "folder")
        }
    }

    @State private var pendingMoveTargets: [ScanDocument] = []

    // MARK: - Capture bar

    private var captureBar: some View {
        GlassGroup(spacing: 10) {
            HStack(spacing: 10) {
                Button(action: startScan) {
                    Label("Scan", systemImage: "doc.viewfinder")
                        .font(.headline)
                        .frame(minWidth: 150)
                        .padding(.vertical, 6)
                }
                .prominentActionStyle()
                .controlSize(.large)
                .accessibilityHint(Text("Opens the camera to scan a document"))

                Menu {
                    importMenuItems
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .frame(width: 26, height: 26)
                        .padding(.vertical, 6)
                }
                .secondaryActionStyle()
                .controlSize(.large)
                .accessibilityLabel(Text("Import"))
            }
        }
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var importMenuItems: some View {
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
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if isSelecting {
            ToolbarItem(placement: .topBarLeading) {
                Button(allSelected ? LocalizedStringKey("Deselect All") : LocalizedStringKey("Select All")) {
                    selection = allSelected ? [] : Set(visibleDocuments.map(\.id))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    isSelecting = false
                    selection.removeAll()
                }
                .fontWeight(.semibold)
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    exportTarget = ExportTarget(documents: selectedDocuments)
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .disabled(selection.isEmpty)

                Spacer()

                Button {
                    mergeSelection()
                } label: {
                    Label("Merge", systemImage: "rectangle.stack.badge.plus")
                }
                .disabled(selection.count < 2)

                Spacer()

                Menu {
                    moveMenu(for: selectedDocuments)
                } label: {
                    Label("Move", systemImage: "folder")
                }
                .disabled(selection.isEmpty)

                Spacer()

                Button(role: .destructive) {
                    requestDelete(selectedDocuments)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(selection.isEmpty)
            }
        } else {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isShowingSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            if !store.isPro {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.showPaywall(.settings)
                    } label: {
                        Label("Go Pro", systemImage: "crown.fill")
                    }
                    .tint(.orange)
                    .accessibilityLabel(Text("Upgrade to Scanlet Pro"))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isSelecting = true
                    } label: {
                        Label("Select", systemImage: "checkmark.circle")
                    }
                    .disabled(visibleDocuments.isEmpty)

                    Picker(selection: $viewMode) {
                        Label("Icons", systemImage: "square.grid.2x2").tag(LibraryViewMode.grid)
                        Label("List", systemImage: "list.bullet").tag(LibraryViewMode.list)
                    } label: {
                        Text("View")
                    }
                    .pickerStyle(.inline)

                    Picker(selection: $sort) {
                        ForEach(LibrarySort.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    } label: {
                        Label("Sort By", systemImage: "arrow.up.arrow.down")
                    }
                    .pickerStyle(.menu)

                    Divider()

                    Button {
                        pendingMoveTargets = []
                        newFolderName = ""
                        isShowingNewFolder = true
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                    importMenuItems
                } label: {
                    Label("More", systemImage: "ellipsis")
                }
            }
        }
    }

    @ViewBuilder
    private var scopeMenu: some View {
        Picker(selection: $scope) {
            Label("All Documents", systemImage: "tray.full").tag(LibraryScope.all)
            Label("Favorites", systemImage: "star").tag(LibraryScope.favorites)
        } label: {
            EmptyView()
        }
        .pickerStyle(.inline)

        if !folders.isEmpty {
            Picker(selection: $scope) {
                ForEach(folders) { folder in
                    Label(folder.name, systemImage: "folder").tag(LibraryScope.folder(folder.id))
                }
            } label: {
                Text("Folders")
            }
            .pickerStyle(.inline)
        }

        Button {
            pendingMoveTargets = []
            newFolderName = ""
            isShowingNewFolder = true
        } label: {
            Label("New Folder…", systemImage: "folder.badge.plus")
        }

        if let folder = currentFolder {
            Button {
                newFolderName = folder.name
                isShowingRenameFolder = true
            } label: {
                Label("Rename Folder…", systemImage: "pencil")
            }
            Button(role: .destructive) {
                isShowingDeleteFolderConfirmation = true
            } label: {
                Label("Delete Folder", systemImage: "trash")
            }
        }
    }

    // MARK: - Derived data

    private var currentFolder: Folder? {
        guard case .folder(let id) = scope else { return nil }
        return folders.first { $0.id == id }
    }

    private var scopeTitle: String {
        switch scope {
        case .all: String(localized: "Documents")
        case .favorites: String(localized: "Favorites")
        case .folder: currentFolder?.name ?? String(localized: "Documents")
        }
    }

    private var visibleDocuments: [ScanDocument] {
        var result: [ScanDocument]
        switch scope {
        case .all: result = documents
        case .favorites: result = documents.filter(\.isFavorite)
        case .folder(let id): result = documents.filter { $0.folder?.id == id }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter {
                $0.title.localizedStandardContains(query) || $0.searchableText.localizedStandardContains(query)
            }
        }

        switch sort {
        case .dateModified: break // Already sorted by the query.
        case .dateCreated: result.sort { $0.createdAt > $1.createdAt }
        case .name: result.sort { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        }
        return result
    }

    private var selectedDocuments: [ScanDocument] {
        visibleDocuments.filter { selection.contains($0.id) }
    }

    private var allSelected: Bool {
        !visibleDocuments.isEmpty && selection.count == visibleDocuments.count
    }

    private var deleteTitle: String {
        deleteTargets.count == 1
            ? String(localized: "Delete Document?")
            : String(localized: "Delete \(deleteTargets.count) Documents?")
    }

    private var renameBinding: Binding<Bool> {
        Binding(get: { renameTarget != nil }, set: { if !$0 { renameTarget = nil } })
    }

    private var errorBinding: Binding<Bool> {
        Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
    }

    // MARK: - Actions

    private func handle(_ action: AppRouter.PendingAction?) {
        guard let action else { return }
        router.pendingAction = nil
        path = NavigationPath()
        switch action {
        case .scan: startScan()
        case .importPhotos: isShowingPhotoPicker = true
        }
    }

    private func startScan() {
        if DocumentCamera.isAvailable {
            isShowingCamera = true
        } else {
            isShowingCameraUnavailable = true
        }
    }

    private func createDocument(from images: [UIImage], autoCrop: Bool) async {
        guard !images.isEmpty else { return }
        isProcessing = true
        let document = await DocumentService.addPages(
            images,
            to: nil,
            folder: currentFolder,
            autoCrop: autoCrop,
            context: modelContext
        )
        isProcessing = false
        scanFeedback.toggle()
        path.append(document)
    }

    private func importPhotos(_ items: [PhotosPickerItem]) async {
        isProcessing = true
        var images: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                images.append(image)
            }
        }
        photoItems = []
        isProcessing = false
        if images.isEmpty {
            errorMessage = String(localized: "The selected photos couldn’t be loaded.")
            return
        }
        await createDocument(from: images, autoCrop: Preferences.autoCropImports)
    }

    private func importFiles(_ result: Result<[URL], Error>) async {
        guard case .success(let urls) = result, !urls.isEmpty else {
            if case .failure(let error) = result { errorMessage = error.localizedDescription }
            return
        }
        isProcessing = true
        var images: [UIImage] = []
        var autoCropImages: [UIImage] = []
        for url in urls {
            if UTType(filenameExtension: url.pathExtension)?.conforms(to: .pdf) == true {
                images += await DocumentService.images(fromPDFAt: url)
            } else {
                let accessing = url.startAccessingSecurityScopedResource()
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    autoCropImages.append(image)
                }
                if accessing { url.stopAccessingSecurityScopedResource() }
            }
        }
        isProcessing = false
        guard !images.isEmpty || !autoCropImages.isEmpty else {
            errorMessage = String(localized: "The selected files couldn’t be opened.")
            return
        }
        // PDF pages are already flat; photos get automatic edge detection.
        if autoCropImages.isEmpty {
            await createDocument(from: images, autoCrop: false)
        } else if images.isEmpty {
            await createDocument(from: autoCropImages, autoCrop: Preferences.autoCropImports)
        } else {
            isProcessing = true
            let document = await DocumentService.addPages(images, to: nil, folder: currentFolder, autoCrop: false, context: modelContext)
            await DocumentService.addPages(autoCropImages, to: document, folder: currentFolder, autoCrop: Preferences.autoCropImports, context: modelContext)
            isProcessing = false
            path.append(document)
        }
    }

    private func toggleSelection(_ document: ScanDocument) {
        if selection.contains(document.id) {
            selection.remove(document.id)
        } else {
            selection.insert(document.id)
        }
    }

    private func requestDelete(_ targets: [ScanDocument]) {
        guard !targets.isEmpty else { return }
        deleteTargets = targets
        isShowingDeleteConfirmation = true
    }

    private func confirmDelete() {
        // Capture IDs before deleting; deleted models must not be read afterwards.
        let ids = deleteTargets.map(\.id)
        withAnimation {
            DocumentService.delete(deleteTargets, context: modelContext)
        }
        selection.subtract(ids)
        deleteTargets = []
        if isSelecting && visibleDocuments.isEmpty { isSelecting = false }
    }

    private func mergeSelection() {
        // Merge in the order the user sees them.
        let targets = selectedDocuments
        guard targets.count > 1 else { return }
        withAnimation {
            _ = DocumentService.merge(targets, context: modelContext)
        }
        selection.removeAll()
        isSelecting = false
    }

    private func move(_ targets: [ScanDocument], to folder: Folder?) {
        withAnimation {
            for document in targets {
                document.folder = folder
            }
        }
        try? modelContext.save()
        selection.removeAll()
        isSelecting = false
    }

    private func commitRename() {
        let name = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let renameTarget, !name.isEmpty else { return }
        renameTarget.title = name
        renameTarget.touch()
        try? modelContext.save()
    }

    private func createFolder() {
        let name = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let folder = Folder(name: name)
        modelContext.insert(folder)
        if pendingMoveTargets.isEmpty {
            scope = .folder(folder.id)
        } else {
            move(pendingMoveTargets, to: folder)
            pendingMoveTargets = []
        }
        try? modelContext.save()
    }

    private func renameCurrentFolder() {
        let name = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let folder = currentFolder, !name.isEmpty else { return }
        folder.name = name
        try? modelContext.save()
    }

    private func deleteCurrentFolder() {
        guard let folder = currentFolder else { return }
        scope = .all
        modelContext.delete(folder)
        try? modelContext.save()
    }
}

/// Documents to export from the library.
struct ExportTarget: Identifiable {
    let id = UUID()
    let documents: [ScanDocument]
}
