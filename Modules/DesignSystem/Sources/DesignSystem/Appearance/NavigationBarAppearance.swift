#if canImport(UIKit)
    import UIKit

    /// Builds the teal navigation-bar appearance from the mock (`#63C6D4`, white title). The App target
    /// applies this to its `NavigationStack` (composition-root concern). Swaps to the darkened
    /// high-contrast teal when Increased Contrast is on, since the mock's teal fails AA under white
    /// (accessibility.md). UIKit-only, so `#if canImport`-guarded to keep the module building on macOS
    /// for the fast test loop.
    public enum NavigationBarAppearance {
        /// `@MainActor` because `UINavigationBarAppearance`'s title attributes are main-actor isolated
        /// (Swift 6), and this is invoked from the App's composition root on the main actor anyway.
        @MainActor
        public static func medalCase(highContrast: Bool = false) -> UINavigationBarAppearance {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            let colorName = highContrast ? "BrandTealHighContrast" : "BrandTeal"
            appearance.backgroundColor = UIColor(named: colorName, in: .module, compatibleWith: nil)
            appearance.shadowColor = .clear
            let titleColor = UIColor.white
            appearance.titleTextAttributes = [.foregroundColor: titleColor]
            appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
            return appearance
        }
    }
#endif
