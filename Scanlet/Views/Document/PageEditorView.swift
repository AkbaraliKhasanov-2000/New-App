import SwiftData
import SwiftUI

/// Edits a single page: filters, rotation, crop and deletion.
struct PageEditorView: View {
    @Bindable var page: ScanPage

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var filterPreviews: [PageFilter: UIImage] = [:]
    @State private var isWorking = false
    @State private var isShowingCrop = false
    @State private var isShowingDelete = false
    @State private var zoom: CGFloat = 1
    @State private var committedZoom: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var committedOffset: CGSize = .zero
    @State private var feedback = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    PageImageView(page: page, maxPixelSize: 2000, contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 4))
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
                        .scaleEffect(zoom)
                        .offset(offset)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .contentShape(.rect)
                        .gesture(zoomGesture.simultaneously(with: panGesture))
                        .onTapGesture(count: 2) {
                            withAnimation(.snappy) {
                                zoom = zoom > 1 ? 1 : 2.5
                                committedZoom = zoom
                                offset = .zero
                                committedOffset = .zero
                            }
                        }
                        .clipped()
                        .accessibilityLabel(Text("Page \(page.index + 1)"))
                        .accessibilityAddTraits(.isImage)
                }
                .padding(20)
                .overlay {
                    if isWorking {
                        ProgressView()
                            .controlSize(.large)
                            .padding(24)
                            .glassSurface(cornerRadius: 18)
                    }
                }

                filterStrip
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(Text("Page \(page.index + 1)"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        rotate(clockwise: false)
                    } label: {
                        Label("Rotate Left", systemImage: "rotate.left")
                    }
                    Spacer()
                    Button {
                        rotate(clockwise: true)
                    } label: {
                        Label("Rotate Right", systemImage: "rotate.right")
                    }
                    Spacer()
                    Button {
                        isShowingCrop = true
                    } label: {
                        Label("Crop", systemImage: "crop")
                    }
                    Spacer()
                    Button(role: .destructive) {
                        isShowingDelete = true
                    } label: {
                        Label("Delete Page", systemImage: "trash")
                    }
                }
            }
            .disabled(isWorking)
            .confirmationDialog("Delete Page?", isPresented: $isShowingDelete, titleVisibility: .visible) {
                Button("Delete Page", role: .destructive) {
                    let target = page
                    dismiss()
                    Task {
                        try? await Task.sleep(for: .milliseconds(350))
                        DocumentService.delete(target, context: modelContext)
                    }
                }
            }
            .fullScreenCover(isPresented: $isShowingCrop) {
                CropEditorView(page: page)
            }
            .task(id: page.originalImageData?.count) {
                await loadFilterPreviews()
            }
            .sensoryFeedback(.selection, trigger: page.filterRawValue)
            .sensoryFeedback(.impact(weight: .light), trigger: feedback)
        }
    }

    // MARK: - Filters

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(PageFilter.allCases) { filter in
                    Button {
                        select(filter)
                    } label: {
                        VStack(spacing: 6) {
                            Group {
                                if let preview = filterPreviews[filter] {
                                    Image(uiImage: preview)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Rectangle().fill(.quaternary)
                                }
                            }
                            .frame(width: 58, height: 76)
                            .clipShape(.rect(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(page.filter == filter ? Color.accentColor : Color.clear, lineWidth: 2.5)
                            }

                            Text(filter.title)
                                .font(.caption2.weight(page.filter == filter ? .semibold : .regular))
                                .foregroundStyle(page.filter == filter ? Color.accentColor : Color.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(filter.accessibilityLabel)
                    .accessibilityAddTraits(page.filter == filter ? .isSelected : [])
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .glassSurface(cornerRadius: 26)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func loadFilterPreviews() async {
        guard let data = page.originalImageData else { return }
        let previews = await Task.detached(priority: .userInitiated) { () -> [PageFilter: UIImage] in
            guard let small = ImageProcessor.thumbnail(from: data, maxPixelSize: 240) else { return [:] }
            var result: [PageFilter: UIImage] = [:]
            for filter in PageFilter.allCases {
                result[filter] = ImageProcessor.apply(filter, to: small)
            }
            return result
        }.value
        filterPreviews = previews
    }

    private func select(_ filter: PageFilter) {
        guard filter != page.filter else { return }
        Task {
            isWorking = true
            await DocumentService.applyFilter(filter, to: page)
            try? modelContext.save()
            isWorking = false
        }
    }

    private func rotate(clockwise: Bool) {
        Task {
            isWorking = true
            await DocumentService.rotate(page, clockwise: clockwise, context: modelContext)
            isWorking = false
            feedback.toggle()
        }
    }

    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                zoom = min(max(committedZoom * value.magnification, 1), 4)
            }
            .onEnded { _ in
                withAnimation(.snappy) {
                    if zoom < 1.05 {
                        zoom = 1
                        offset = .zero
                        committedOffset = .zero
                    }
                    committedZoom = zoom
                }
            }
    }

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                guard zoom > 1 else { return }
                offset = CGSize(
                    width: committedOffset.width + value.translation.width,
                    height: committedOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                committedOffset = offset
            }
    }
}
