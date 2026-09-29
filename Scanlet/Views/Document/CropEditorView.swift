import SwiftData
import SwiftUI

/// Manual four-corner crop with perspective correction.
struct CropEditorView: View {
    let page: ScanPage

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var image: UIImage?
    @State private var quad: Quadrilateral = .inset
    @State private var detectedQuad: Quadrilateral?
    @State private var activeCorner: Int?
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                if let image {
                    let rect = DocumentExporter.aspectFitRect(
                        for: image.size,
                        in: CGRect(origin: .zero, size: proxy.size).insetBy(dx: 24, dy: 24)
                    )
                    ZStack(alignment: .topLeading) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: rect.width, height: rect.height)
                            .offset(x: rect.minX, y: rect.minY)
                            .accessibilityHidden(true)

                        CropMask(quad: quad, imageRect: rect)
                            .fill(.black.opacity(0.45), style: FillStyle(eoFill: true))
                            .allowsHitTesting(false)

                        CropOutline(quad: quad, imageRect: rect)
                            .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                            .allowsHitTesting(false)

                        ForEach(0..<4, id: \.self) { index in
                            handle(index: index, in: rect)
                        }
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color.black)
            .navigationTitle("Crop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar, .bottomBar)
            .toolbarColorScheme(.dark, for: .navigationBar, .bottomBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { apply() }
                        .fontWeight(.semibold)
                        .disabled(isSaving || image == nil)
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        withAnimation(.snappy) { quad = .fullFrame }
                    } label: {
                        Label("Full Page", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                    Spacer()
                    Button {
                        withAnimation(.snappy) { quad = detectedQuad ?? .inset }
                    } label: {
                        Label("Auto Detect", systemImage: "viewfinder")
                    }
                    .disabled(detectedQuad == nil)
                }
            }
            .overlay {
                if isSaving { ProcessingOverlay(title: "Applying crop…") }
            }
            .task { await load() }
            .sensoryFeedback(.selection, trigger: activeCorner)
        }
    }

    private func handle(index: Int, in rect: CGRect) -> some View {
        let point = quad.corners[index]
        let position = CGPoint(x: rect.minX + point.x * rect.width, y: rect.minY + point.y * rect.height)
        return Circle()
            .fill(.white)
            .frame(width: 22, height: 22)
            .overlay(Circle().strokeBorder(Color.accentColor, lineWidth: 3))
            .shadow(color: .black.opacity(0.35), radius: 3)
            .scaleEffect(activeCorner == index ? 1.35 : 1)
            .frame(width: 48, height: 48) // Comfortable hit target.
            .contentShape(.circle)
            .position(position)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        activeCorner = index
                        let x = min(max((value.location.x - rect.minX) / rect.width, 0), 1)
                        let y = min(max((value.location.y - rect.minY) / rect.height, 0), 1)
                        update(corner: index, to: CGPoint(x: x, y: y))
                    }
                    .onEnded { _ in activeCorner = nil }
            )
            .animation(.snappy(duration: 0.15), value: activeCorner)
            .accessibilityElement()
            .accessibilityLabel(Text(cornerName(index)))
            .accessibilityAdjustableAction { direction in
                let step: CGFloat = direction == .increment ? 0.02 : -0.02
                var point = quad.corners[index]
                point.x = min(max(point.x + (index == 0 || index == 3 ? step : -step), 0), 1)
                point.y = min(max(point.y + (index < 2 ? step : -step), 0), 1)
                update(corner: index, to: point)
            }
    }

    private func cornerName(_ index: Int) -> LocalizedStringKey {
        switch index {
        case 0: "Top-left corner"
        case 1: "Top-right corner"
        case 2: "Bottom-right corner"
        default: "Bottom-left corner"
        }
    }

    private func update(corner index: Int, to point: CGPoint) {
        switch index {
        case 0: quad.topLeft = point
        case 1: quad.topRight = point
        case 2: quad.bottomRight = point
        default: quad.bottomLeft = point
        }
    }

    private func load() async {
        guard let data = page.originalImageData else { return }
        let result = await Task.detached(priority: .userInitiated) { () -> (UIImage?, Quadrilateral?) in
            guard let image = UIImage(data: data) else { return (nil, nil) }
            let normalized = ImageProcessor.normalized(image)
            return (normalized, ImageProcessor.detectDocument(in: normalized))
        }.value
        image = result.0
        detectedQuad = result.1
        quad = result.1 ?? .fullFrame
    }

    private func apply() {
        let corners = quad
        guard corners != .fullFrame else {
            dismiss()
            return
        }
        isSaving = true
        Task {
            await DocumentService.transform(page, context: modelContext) { image in
                ImageProcessor.perspectiveCorrected(image, corners: corners)
            }
            isSaving = false
            dismiss()
        }
    }
}

/// Darkens everything outside the crop quadrilateral.
private struct CropMask: Shape {
    let quad: Quadrilateral
    let imageRect: CGRect

    func path(in rect: CGRect) -> Path {
        var path = Path(imageRect)
        path.addPath(CropOutline(quad: quad, imageRect: imageRect).path(in: rect))
        return path
    }
}

private struct CropOutline: Shape {
    let quad: Quadrilateral
    let imageRect: CGRect

    func path(in rect: CGRect) -> Path {
        let points = quad.corners.map {
            CGPoint(x: imageRect.minX + $0.x * imageRect.width, y: imageRect.minY + $0.y * imageRect.height)
        }
        var path = Path()
        path.addLines(points)
        path.closeSubpath()
        return path
    }
}
