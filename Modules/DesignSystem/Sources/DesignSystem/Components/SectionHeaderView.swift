import SwiftUI

/// A section's header strip (`#F7F7F7`): the title, and — only when the section declares it — a
/// right-aligned "N of M" progress count (R1.2). The count is passed in already computed (ADR-0008);
/// this view never counts. Carries the VoiceOver heading trait (R4.2).
public struct SectionHeaderView: View {
    private let title: String
    private let progress: (earned: Int, total: Int)?

    public init(title: String, progress: (earned: Int, total: Int)? = nil) {
        self.title = title
        self.progress = progress
    }

    public var body: some View {
        HStack {
            Text(title)
                .medalFont(Typography.sectionTitle)
                .foregroundStyle(SemanticColor.sectionTitle)
            Spacer()
            if let progress {
                Text("\(progress.earned) of \(progress.total)", bundle: .module)
                    .medalFont(Typography.sectionCount)
                    .foregroundStyle(SemanticColor.sectionCount)
            }
        }
        .padding(.horizontal, Spacing.stripHorizontal)
        .padding(.vertical, Spacing.stripVertical)
        .frame(maxWidth: .infinity)
        .background(SemanticColor.sectionStrip)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(Text(accessibilityLabel))
    }

    /// "«title», N of M earned" (R4.2) — a `LocalizedStringResource` with an explicit module bundle so
    /// the "earned" phrasing resolves against this package's localization tables (a bare interpolated
    /// key would look in the app's main bundle and always speak English). Rendered through `Text`
    /// under the `\.locale` environment, so it follows the app's **effective** language — the switcher
    /// UI test pins the fully-French "Records personnels, 5 sur 6 obtenues" (accessibility.md).
    private var accessibilityLabel: LocalizedStringResource {
        guard let progress else { return "\(title)" }
        return LocalizedStringResource(
            "\(title), \(progress.earned) of \(progress.total) earned",
            bundle: .atURL(Bundle.module.bundleURL)
        )
    }
}
