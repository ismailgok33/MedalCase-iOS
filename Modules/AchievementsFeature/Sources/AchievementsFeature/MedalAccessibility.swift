import Foundation
import MedalDomain

/// Builds a medal cell's single VoiceOver label (R4.1): "«title», «value»" when earned with a value,
/// "«title», not yet earned" when locked, just the title when earned without a value. Pure, so the
/// label structure is unit-tested (via `String(localized:)`) without rendering. Returns a
/// `LocalizedStringResource` so "not yet earned" resolves against the String Catalog.
enum MedalAccessibility {
    static func label(for medal: Achievement) -> LocalizedStringResource {
        switch medal.status {
        case let .earned(value):
            if let valueString = MedalValueFormatter.string(for: value) {
                return "\(medal.title), \(valueString)"
            }
            return "\(medal.title)"
        case .locked:
            // Explicit bundle so "not yet earned" resolves against this package's String Catalog
            // (interpolated LocalizedStringResource literals default to the app's main bundle).
            return LocalizedStringResource(
                "\(medal.title), not yet earned",
                bundle: .atURL(Bundle.module.bundleURL)
            )
        }
    }
}
