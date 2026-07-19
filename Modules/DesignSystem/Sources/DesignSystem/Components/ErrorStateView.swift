import SwiftUI

/// The error surface — a localized message and, when retryable, a Retry button that re-runs the load
/// (R2.2). Never shows a raw error string.
public struct ErrorStateView: View {
    private let message: LocalizedStringResource
    private let isRetryable: Bool
    private let retry: () -> Void

    public init(message: LocalizedStringResource, isRetryable: Bool = true, retry: @escaping () -> Void) {
        self.message = message
        self.isRetryable = isRetryable
        self.retry = retry
    }

    public var body: some View {
        VStack(spacing: Spacing.stateSpacing) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .medalFont(Typography.medalValue)
                .foregroundStyle(SemanticColor.medalValue)
                .multilineTextAlignment(.center)
            if isRetryable {
                Button("Retry", action: retry)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
