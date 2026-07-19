import SwiftUI

/// The empty surface — shown when there are no medals to display (R2.3). Calm and explanatory, not an
/// error.
public struct EmptyStateView: View {
    /// A pre-resolved `Text` (not a LocalizedStringKey): the caller localizes against its own package
    /// catalog (`Text("…", bundle: .module)`) — a bare key rendered here would resolve against the app's
    /// main bundle and miss every package catalog.
    private let message: Text

    public init(message: Text) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: Spacing.stateSpacing) {
            Image(systemName: "medal")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            message
                .medalFont(Typography.medalValue)
                .foregroundStyle(SemanticColor.medalValue)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
