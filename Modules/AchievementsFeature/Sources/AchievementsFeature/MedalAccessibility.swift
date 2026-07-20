import Foundation
import MedalDomain

/// Builds a medal cell's single VoiceOver label (R4.1): "«title», «value»" when earned with a value,
/// "«title», not yet earned" when locked, just the title when earned without a value. Pure, so the
/// label structure is unit-tested (via `String(localized:)`) without rendering. The composite forms
/// come from `L10n`, so their phrasing resolves against this package's localization tables.
enum MedalAccessibility {
    static func label(for medal: Achievement) -> LocalizedStringResource {
        switch medal.status {
        case let .earned(value):
            if let valueString = MedalValueFormatter.string(for: value) {
                return L10n.earnedMedalLabel(title: medal.title, value: valueString)
            }
            return "\(medal.title)"
        case .locked:
            return L10n.lockedMedalLabel(title: medal.title)
        }
    }
}
