import SwiftUI

/// The empty surface — shown when there are no medals to display (R2.3). Calm and explanatory, not an
/// error.
public struct EmptyStateView: View {
    private let message: LocalizedStringKey

    public init(message: LocalizedStringKey) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: Spacing.stateSpacing) {
            Image(systemName: "medal")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .medalFont(Typography.medalValue)
                .foregroundStyle(SemanticColor.medalValue)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
