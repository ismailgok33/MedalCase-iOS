import DesignSystem
import MedalDomain
import SwiftUI

/// One grid cell: badge on top, title, then the value line (or the localized "Not Yet" for a locked
/// medal). The whole cell is a single accessibility element (R4.1) — the badge is decorative and the
/// cell owns the combined label.
public struct MedalCellView: View {
    private let medal: Achievement

    public init(medal: Achievement) {
        self.medal = medal
    }

    public var body: some View {
        VStack(spacing: Spacing.cellSpacing) {
            MedalBadgeView(assetKey: medal.assetKey, isLocked: !medal.isEarned)
            Text(medal.title)
                .medalFont(Typography.medalTitle)
                .foregroundStyle(SemanticColor.medalTitle)
                .multilineTextAlignment(.center)
            valueText
                .medalFont(Typography.medalValue)
                .foregroundStyle(SemanticColor.medalValue)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.cellPadding)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(MedalAccessibility.label(for: medal)))
    }

    private var valueText: Text {
        switch medal.status {
        case let .earned(value):
            // Value glyphs (23:07, 2095 ft) are numeric, not prose → verbatim, never localized.
            Text(verbatim: MedalValueFormatter.string(for: value) ?? " ")
        case .locked:
            Text("Not Yet", bundle: .module)
        }
    }
}
