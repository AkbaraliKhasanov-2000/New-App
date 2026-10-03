import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var index = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            symbol: "doc.viewfinder",
            colors: [.blue, .indigo],
            title: "Scan Anything in Seconds",
            message: "Edges are detected and straightened automatically. Documents, receipts, IDs and notes come out crisp and clean."
        ),
        OnboardingPage(
            symbol: "text.viewfinder",
            colors: [.indigo, .purple],
            title: "Turn Images into Text",
            message: "Scanlet reads text right on your iPhone. Search every scan, copy, translate and create searchable PDFs."
        ),
        OnboardingPage(
            symbol: "signature",
            colors: [.purple, .pink],
            title: "Sign, Protect and Share",
            message: "Add your signature, lock PDFs with a password and share anywhere. Your documents never leave your device."
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.offset) { offset, page in
                    OnboardingPageView(page: page, isActive: offset == index)
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.snappy, value: index)

            VStack(spacing: 18) {
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { dot in
                        Capsule()
                            .fill(dot == index ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: dot == index ? 22 : 8, height: 8)
                    }
                }
                .animation(.snappy, value: index)
                .accessibilityElement()
                .accessibilityLabel(Text("Page \(index + 1) of \(pages.count)"))

                Button {
                    if index < pages.count - 1 {
                        index += 1
                    } else {
                        onFinish()
                    }
                } label: {
                    Text(index < pages.count - 1 ? LocalizedStringKey("Continue") : LocalizedStringKey("Get Started"))
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .prominentActionStyle()
                .controlSize(.large)

                Button("Skip") { onFinish() }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .opacity(index < pages.count - 1 ? 1 : 0)
                    .disabled(index == pages.count - 1)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .sensoryFeedback(.selection, trigger: index)
    }
}

private struct OnboardingPage {
    let symbol: String
    let colors: [Color]
    let title: LocalizedStringKey
    let message: LocalizedStringKey
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: page.colors.map { $0.opacity(0.18) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 230, height: 230)
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(LinearGradient(colors: page.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 140, height: 140)
                    .shadow(color: page.colors[0].opacity(0.4), radius: 24, y: 12)
                Image(systemName: page.symbol)
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: isActive)
            }
            .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text(page.message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
            .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}
