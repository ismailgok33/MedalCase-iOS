import SwiftUI

/// The grid's loading state: redacted placeholder cells rather than a bare spinner, so the layout is
/// visible while data loads. Collapses to a single "Loading" element for VoiceOver.
public struct AchievementsGridSkeleton: View {
    private let cellCount: Int

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.columnSpacing),
        GridItem(.flexible(), spacing: Spacing.columnSpacing)
    ]

    public init(cellCount: Int = 6) {
        self.cellCount = cellCount
    }

    public var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.gridGutter) {
            ForEach(0 ..< cellCount, id: \.self) { _ in
                RoundedRectangle(cornerRadius: Radius.cell)
                    .fill(SemanticColor.sectionStrip)
                    .frame(height: Spacing.badgeSize + Spacing.gridGutter)
            }
        }
        .padding(Spacing.gridGutter)
        .redacted(reason: .placeholder)
        .accessibilityElement()
        .accessibilityLabel(Text(LocalizedStringResource("Loading", bundle: .atURL(Bundle.module.bundleURL))))
    }
}
