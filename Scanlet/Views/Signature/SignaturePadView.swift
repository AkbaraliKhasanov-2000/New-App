import PencilKit
import SwiftUI

/// Draw a signature with a finger or Apple Pencil.
struct SignaturePadView: View {
    let onSave: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var drawing = PKDrawing()
    @State private var inkColor: InkColor = .black

    enum InkColor: String, CaseIterable, Identifiable {
        case black, blue, red
        var id: String { rawValue }
        var color: UIColor {
            switch self {
            case .black: UIColor(white: 0.05, alpha: 1)
            case .blue: UIColor(red: 0.07, green: 0.22, blue: 0.62, alpha: 1)
            case .red: UIColor(red: 0.72, green: 0.1, blue: 0.12, alpha: 1)
            }
        }
        var name: LocalizedStringKey {
            switch self {
            case .black: "Black"
            case .blue: "Blue"
            case .red: "Red"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ZStack(alignment: .bottom) {
                    SignatureCanvas(drawing: $drawing, color: inkColor.color)
                        .background(Color.white)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16).strokeBorder(.separator)
                        }
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(height: 1)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 56)
                        .allowsHitTesting(false)
                    if drawing.strokes.isEmpty {
                        Text("Sign here")
                            .font(.title3)
                            .foregroundStyle(Color.gray.opacity(0.6))
                            .padding(.bottom, 64)
                            .allowsHitTesting(false)
                    }
                }
                .frame(height: 260)
                .environment(\.colorScheme, .light)

                Picker("Ink Color", selection: $inkColor) {
                    ForEach(InkColor.allCases) { ink in
                        Text(ink.name).tag(ink)
                    }
                }
                .pickerStyle(.segmented)

                Spacer()
            }
            .padding(20)
            .navigationTitle("New Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(drawing.strokes.isEmpty)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Clear", role: .destructive) {
                        drawing = PKDrawing()
                    }
                    .disabled(drawing.strokes.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        let bounds = drawing.bounds.insetBy(dx: -8, dy: -8)
        // Render in light mode so ink colors are exact.
        var image = UIImage()
        UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
            image = drawing.image(from: bounds, scale: 3)
        }
        onSave(image)
        dismiss()
    }
}

private struct SignatureCanvas: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    let color: UIColor

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.overrideUserInterfaceStyle = .light
        canvas.tool = PKInkingTool(.pen, color: color, width: 4)
        canvas.delegate = context.coordinator
        canvas.drawing = drawing
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.tool = PKInkingTool(.pen, color: color, width: 4)
        // The only external change is "Clear".
        if drawing.strokes.isEmpty && !canvas.drawing.strokes.isEmpty {
            canvas.drawing = PKDrawing()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(drawing: $drawing) }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}
