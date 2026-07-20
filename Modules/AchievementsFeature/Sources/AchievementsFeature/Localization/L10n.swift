import Foundation

/// This module's **resource-form** localized strings — the ones that must exist as
/// `LocalizedStringResource` values (accessibility labels, the error message) rather than inline
/// `Text` keys. Centralizing them puts the module-bundle plumbing in exactly one place — a call site
/// can no longer silently resolve against the app's main bundle (rule 5). Single-use visual strings
/// stay inline as `Text("…", bundle: .module)`, the platform idiom; see ADR-0012.
enum L10n {
    /// The overflow menu button's VoiceOver label.
    static var moreOptions: LocalizedStringResource {
        LocalizedStringResource("More options", bundle: moduleBundle)
    }

    /// The single user-facing load-failure message (R2.2).
    static var loadFailureMessage: LocalizedStringResource {
        LocalizedStringResource("We couldn't load your medals. Please try again.", bundle: moduleBundle)
    }

    /// Locked medal cell label: "«title», not yet earned" (R4.1).
    static func lockedMedalLabel(title: String) -> LocalizedStringResource {
        LocalizedStringResource("\(title), not yet earned", bundle: moduleBundle)
    }

    /// Earned medal cell label: "«title», «value»" — format-only today (every language renders the
    /// arguments verbatim), but routed through the table so a locale could reorder the parts.
    static func earnedMedalLabel(title: String, value: String) -> LocalizedStringResource {
        LocalizedStringResource("\(title), \(value)", bundle: moduleBundle)
    }

    private static var moduleBundle: LocalizedStringResource.BundleDescription {
        .atURL(Bundle.module.bundleURL)
    }
}
