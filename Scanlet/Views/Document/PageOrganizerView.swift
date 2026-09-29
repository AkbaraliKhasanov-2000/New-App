import SwiftData
import SwiftUI

/// Reorder and delete pages with the standard list editing interactions.
struct PageOrganizerView: View {
    let document: ScanDocument

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(document.orderedPages.enumerated()), id: \.element.id) { offset, page in
                    HStack(spacing: 16) {
                        PaperThumbnail(page: page, maxPixelSize: 200, cornerRadius: 6)
                            .frame(width: 54, height: 70)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Page \(offset + 1)")
                                .font(.body.weight(.semibold))
                            if let text = page.recognizedText, !text.isEmpty {
                                Text(text)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                }
                .onMove { source, destination in
                    DocumentService.movePages(in: document, from: source, to: destination)
                    try? modelContext.save()
                }
                .onDelete { offsets in
                    let pages = document.orderedPages
                    for offset in offsets.sorted(by: >) where pages.indices.contains(offset) {
                        DocumentService.delete(pages[offset], context: modelContext)
                    }
                    if document.pages.isEmpty { dismiss() }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Organize Pages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
