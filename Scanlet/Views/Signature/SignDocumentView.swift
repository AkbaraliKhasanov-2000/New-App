import SwiftData
import SwiftUI

/// Pick a page, pick (or draw) a signature, then place and resize it.
struct SignDocumentView: View {
    let document: ScanDocument

    @Environment(\.dismiss) private var dismiss
    @Environment(SignatureLibrary.self) private var signatures

    @State private var selectedPage: ScanPage?
    @State private var selectedSignature: SignatureLibrary.Signature?
    @State private var isShowingPad = false

    var body: some View {
        NavigationStack {
            Group {
                if let selectedPage, let selectedSignature {
                    SignaturePlacementView(page: selectedPage, signature: selectedSignature.image) {
                        dismiss()
                    }
                } else {
                    Form {
                        signatureSection
                        if document.pageCount > 1 {
                            pageSection
                        }
                    }
                }
            }
            .navigationTitle("Sign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $isShowingPad) {
                SignaturePadView { image in
                    if let saved = signatures.save(image) {
                        choose(saved)
                    }
                }
            }
            .onAppear {
                if document.pageCount == 1 { selectedPage = document.coverPage }
            }
        }
    }

    private var signatureSection: some View {
        Section {
            ForEach(signatures.signatures) { signature in
                Button {
                    choose(signature)
                } label: {
                    Image(uiImage: signature.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .accessibilityLabel(Text("Saved signature"))
                .swipeActions {
                    Button(role: .destructive) {
                        signatures.delete(signature)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            Button {
                isShowingPad = true
            } label: {
                Label("New Signature", systemImage: "signature")
            }
        } header: {
            Text("Signature")
        } footer: {
            if document.pageCount > 1 && selectedPage == nil {
                Text("Choose a page below, then pick a signature.")
            } else {
                Text("Signatures are stored only on this device.")
            }
        }
    }

    private var pageSection: some View {
        Section("Page") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(document.orderedPages.enumerated()), id: \.element.id) { offset, page in
                        Button {
                            selectedPage = page
                        } label: {
                            VStack(spacing: 6) {
                                PaperThumbnail(page: page, maxPixelSize: 220, cornerRadius: 6)
                                    .frame(width: 70, height: 92)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(selectedPage?.id == page.id ? Color.accentColor : .clear, lineWidth: 3)
                                    }
                                Text("\(offset + 1)")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(selectedPage?.id == page.id ? Color.accentColor : Color.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Page \(offset + 1)"))
                        .accessibilityAddTraits(selectedPage?.id == page.id ? .isSelected : [])
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    private func choose(_ signature: SignatureLibrary.Signature) {
        if selectedPage == nil {
            selectedPage = document.coverPage
        }
        withAnimation { selectedSignature = signature }
    }
}

/// Drag and pinch to position the signature, then flatten it into the page.
struct SignaturePlacementView: View {
    let page: ScanPage
    let signature: UIImage
    let onFinish: () -> Void

    @Environment(\.modelContext) private var modelContext

    /// Center of the signature, normalized to the page (top-left origin).
    @State private var center = CGPoint(x: 0.7, y: 0.82)
    @State private var dragStart: CGPoint?
    /// Width of the signature as a fraction of page width.
    @State private var widthFraction: CGFloat = 0.34
    @State private var pinchStart: CGFloat?
    @State private var pageImage: UIImage?
    @State private var isSaving = false

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { proxy in
                if let pageImage {
                    let rect = DocumentExporter.aspectFitRect(
                        for: pageImage.size,
                        in: CGRect(origin: .zero, size: proxy.size).insetBy(dx: 16, dy: 16)
                    )
                    let signatureSize = CGSize(
                        width: rect.width * widthFraction,
                        height: rect.width * widthFraction * signature.size.height / max(signature.size.width, 1)
                    )
                    ZStack(alignment: .topLeading) {
                        Image(uiImage: pageImage)
                            .resizable()
                            .frame(width: rect.width, height: rect.height)
                            .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
                            .offset(x: rect.minX, y: rect.minY)

                        Image(uiImage: signature)
                            .resizable()
                            .frame(width: signatureSize.width, height: signatureSize.height)
                            .padding(6)
                            .overlay {
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                            }
                            .position(
                                x: rect.minX + center.x * rect.width,
                                y: rect.minY + center.y * rect.height
                            )
                            .gesture(dragGesture(in: rect).simultaneously(with: pinchGesture))
                            .accessibilityLabel(Text("Signature"))
                            .accessibilityHint(Text("Drag to move. Pinch to resize."))
                    }
                } else {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "textformat.size.smaller")
                        .accessibilityHidden(true)
                    Slider(value: $widthFraction, in: 0.12...0.8) {
                        Text("Signature Size")
                    }
                    Image(systemName: "textformat.size.larger")
                        .accessibilityHidden(true)
                }
                .foregroundStyle(.secondary)

                Button {
                    save()
                } label: {
                    Text("Place Signature")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .prominentActionStyle()
                .controlSize(.large)
                .disabled(isSaving || pageImage == nil)
            }
            .padding(16)
            .glassSurface(cornerRadius: 28)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .background(Color(.systemGroupedBackground))
        .overlay {
            if isSaving { ProcessingOverlay(title: "Signing…") }
        }
        .task {
            guard let data = page.originalImageData else { return }
            pageImage = await Task.detached { UIImage(data: data).map(ImageProcessor.normalized) }.value
        }
    }

    private func dragGesture(in rect: CGRect) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let start = dragStart ?? center
                if dragStart == nil { dragStart = center }
                center = CGPoint(
                    x: min(max(start.x + value.translation.width / rect.width, 0.05), 0.95),
                    y: min(max(start.y + value.translation.height / rect.height, 0.03), 0.97)
                )
            }
            .onEnded { _ in dragStart = nil }
    }

    private var pinchGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let start = pinchStart ?? widthFraction
                if pinchStart == nil { pinchStart = widthFraction }
                widthFraction = min(max(start * value.magnification, 0.12), 0.8)
            }
            .onEnded { _ in pinchStart = nil }
    }

    private func save() {
        guard let pageImage else { return }
        let aspect = signature.size.height / max(signature.size.width, 1)
        let widthFraction = widthFraction
        // Height fraction is relative to page height.
        let heightFraction = widthFraction * aspect * pageImage.size.width / max(pageImage.size.height, 1)
        let rect = CGRect(
            x: center.x - widthFraction / 2,
            y: center.y - heightFraction / 2,
            width: widthFraction,
            height: heightFraction
        )
        let signature = signature
        isSaving = true
        Task {
            await DocumentService.transform(page, context: modelContext, invalidatesText: false) { image in
                ImageProcessor.composite(signature, onto: image, normalizedRect: rect)
            }
            isSaving = false
            onFinish()
        }
    }
}
