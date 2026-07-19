import SwiftUI

/// The mock's colors, in one place (CLAUDE.md rule 5). Every value is an adaptive light/dark colorset
/// in the asset catalog, so contrast holds in both appearances. `brandTealHighContrast` is the
/// darkened teal used when Increased Contrast is on, since the mock's teal fails AA under white
/// (accessibility.md).
public enum SemanticColor {
    public static let brandTeal = Color("BrandTeal", bundle: .module)
    public static let brandTealHighContrast = Color("BrandTealHighContrast", bundle: .module)
    public static let navTitle = Color.white
    public static let sectionTitle = Color("SectionTitle", bundle: .module)
    public static let sectionCount = Color("SectionCount", bundle: .module)
    public static let medalTitle = Color("MedalTitle", bundle: .module)
    public static let medalValue = Color("MedalValue", bundle: .module)
    public static let sectionStrip = Color("SectionStrip", bundle: .module)
    public static let surface = Color("Surface", bundle: .module)
}
