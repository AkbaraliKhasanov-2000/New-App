#if DEBUG
import SwiftData
import UIKit

/// Sample documents for simulator runs and App Store screenshots (Debug builds only).
///
/// Launch arguments:
/// - `-seedDemoContent YES` creates sample scans when the library is empty.
/// - `-demoScreen detail|settings|paywall` opens a screen after launch.
@MainActor
enum DemoContent {
    static var isSeedingEnabled: Bool {
        UserDefaults.standard.bool(forKey: "seedDemoContent")
    }

    static var screen: String? {
        UserDefaults.standard.string(forKey: "demoScreen")
    }

    static func seedIfNeeded(context: ModelContext) async {
        guard isSeedingEnabled else { return }
        let existing = (try? context.fetchCount(FetchDescriptor<ScanDocument>())) ?? 0
        guard existing == 0 else { return }

        let samples: [(title: String, lines: [String], favorite: Bool)] = [
            ("Invoice #4471", [
                "INVOICE #4471", "", "Northwind Design Studio", "221 Market Street, San Francisco",
                "", "Bill to: Aziz Karimov", "Date: September 29, 2026", "",
                "Brand identity package          $1,200.00", "Website design (5 pages)        $2,400.00",
                "App icon set                      $350.00", "", "Subtotal                        $3,950.00",
                "Tax (8.5%)                        $335.75", "TOTAL DUE                       $4,285.75",
            ], true),
            ("Rental Agreement", [
                "RESIDENTIAL LEASE AGREEMENT", "", "This agreement is made between the Landlord",
                "and the Tenant for the property located at", "14 Amir Temur Avenue, Apartment 32.", "",
                "1. TERM. The lease begins on October 1, 2026", "and ends on September 30, 2027.", "",
                "2. RENT. Monthly rent is due on the first day", "of each month.", "",
                "3. DEPOSIT. A security deposit equal to one", "month of rent is due at signing.",
            ], false),
            ("Coffee Receipt", [
                "BLUE BOTTLE COFFEE", "Receipt 00821", "", "Oat Latte              $5.75",
                "Croissant              $4.25", "Cold Brew              $5.00", "",
                "Total                 $15.00", "Visa •••• 4242", "", "Thank you!",
            ], false),
        ]

        for sample in samples {
            let image = renderPage(lines: sample.lines)
            let document = await DocumentService.addPages([image], to: nil, folder: nil, autoCrop: false, context: context)
            document.title = sample.title
            document.isFavorite = sample.favorite
        }
        try? context.save()
    }

    private static func renderPage(lines: [String]) -> UIImage {
        let size = CGSize(width: 1240, height: 1754)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor(white: 0.97, alpha: 1).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            var y: CGFloat = 140
            for (index, line) in lines.enumerated() {
                let isTitle = index == 0
                let font = isTitle
                    ? UIFont.systemFont(ofSize: 64, weight: .bold)
                    : UIFont.monospacedSystemFont(ofSize: 34, weight: .regular)
                (line as NSString).draw(at: CGPoint(x: 110, y: y), withAttributes: [
                    .font: font,
                    .foregroundColor: UIColor(white: 0.12, alpha: 1),
                ])
                y += isTitle ? 110 : 64
            }
        }
    }
}
#endif
