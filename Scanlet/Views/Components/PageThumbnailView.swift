import SwiftUI

/// Asynchronously decoded, cached page image.
struct PageImageView: View {
    let page: ScanPage
    var maxPixelSize: CGFloat = 400
    var contentMode: ContentMode = .fit

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity)
            } else {
                Rectangle()
                    .fill(.quaternary)
                    .overlay { ProgressView() }
            }
        }
        .task(id: "\(page.cacheKey)@\(Int(maxPixelSize))") {
            let loaded = await ThumbnailCache.shared.thumbnail(
                key: page.cacheKey,
                data: page.imageData ?? page.originalImageData,
                maxPixelSize: maxPixelSize
            )
            withAnimation(.easeOut(duration: 0.15)) { image = loaded }
        }
        .accessibilityHidden(true)
    }
}

/// Paper-like thumbnail with a hairline border and soft shadow.
struct PaperThumbnail: View {
    let page: ScanPage?
    var maxPixelSize: CGFloat = 360
    var cornerRadius: CGFloat = 10

    var body: some View {
        Group {
            if let page {
                PageImageView(page: page, maxPixelSize: maxPixelSize, contentMode: .fill)
            } else {
                Rectangle().fill(.quaternary)
                    .overlay {
                        Image(systemName: "doc")
                            .font(.title)
                            .foregroundStyle(.tertiary)
                    }
            }
        }
        .clipShape(.rect(cornerRadius: cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(.separator, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
}
