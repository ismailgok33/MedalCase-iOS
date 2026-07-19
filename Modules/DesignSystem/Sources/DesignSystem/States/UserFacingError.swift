import Foundation

/// A presentation-ready error: a localized message plus whether a Retry affordance should show. The
/// feature maps `MedalError → UserFacingError`, so the domain error taxonomy never reaches the UI
/// (CLAUDE.md — errors are values).
///
/// `message` is a `LocalizedStringResource` (not `LocalizedStringKey`) because this value crosses the
/// `@MainActor` ViewModel → View boundary inside `ViewState`, and only `LocalizedStringResource` is
/// `Sendable`. It still resolves against the String Catalog when rendered by `Text`.
public struct UserFacingError: Error, Equatable, Sendable {
    public let message: LocalizedStringResource
    public let isRetryable: Bool

    public init(message: LocalizedStringResource, isRetryable: Bool) {
        self.message = message
        self.isRetryable = isRetryable
    }
}
