import Foundation

/// The in-app language override (EN/FR) — a demo affordance surfaced in the overflow menu (R1.6) so a
/// reviewer can flip the app's language without leaving it. `AchievementsView` persists the raw value
/// via `AppStorage` and applies `.environment(\.locale)`, which re-resolves every localization-table lookup
/// live (ADR-0012). Injectable at launch for tests/screenshots: `-app_language fr`.
///
/// Public because the **composition root** also reads it: the repository's language provider
/// (ADR-0013) resolves the same stored value + system-default fallback, so chrome and content can
/// never disagree about the current language.
public enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case french = "fr"

    /// The AppStorage/UserDefaults key.
    public static let storageKey = "app_language"

    /// First-launch seed: a French-system device starts in French without touching the switcher
    /// (ADR-0012). Pure overload so the mapping is unit-testable.
    public static var systemDefault: AppLanguage {
        defaultLanguage(forPreferred: Locale.preferredLanguages)
    }

    static func defaultLanguage(forPreferred preferred: [String]) -> AppLanguage {
        guard let first = preferred.first else { return .english }
        return first.lowercased().hasPrefix("fr") ? .french : .english
    }

    public var id: String {
        rawValue
    }

    /// Each language names itself in its own language (standard picker practice) — deliberately
    /// verbatim, never localized.
    var displayName: String {
        switch self {
        case .english: "English"
        case .french: "Français"
        }
    }
}
