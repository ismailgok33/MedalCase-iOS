import Foundation

/// This module's **resource-form** localized strings — the ones that must exist as
/// `LocalizedStringResource` values (accessibility labels and formats) rather than inline `Text`
/// keys. Centralizing them puts the module-bundle plumbing in exactly one place — a call site can no
/// longer silently resolve against the app's main bundle — and shared keys ("Loading") are defined
/// once (rule 5). Single-use visual strings stay inline as `Text("…", bundle: .module)`, the
/// platform idiom; see ADR-0012 for the table mechanics.
enum L10n {
    /// The shared VoiceOver label for the loading surfaces (`LoadingView`, `AchievementsGridSkeleton`).
    static var loading: LocalizedStringResource {
        LocalizedStringResource("Loading", bundle: moduleBundle)
    }

    /// The section header's combined VoiceOver label: "«title», N of M earned" (R4.2). Rendered
    /// through `Text` under `\.locale`, so it follows the app's effective language.
    static func sectionHeaderLabel(title: String, earned: Int, total: Int) -> LocalizedStringResource {
        LocalizedStringResource("\(title), \(earned) of \(total) earned", bundle: moduleBundle)
    }

    private static var moduleBundle: LocalizedStringResource.BundleDescription {
        .atURL(Bundle.module.bundleURL)
    }
}
