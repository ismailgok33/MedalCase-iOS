import SwiftUI

/// Applies a `TypographyToken` as a system font whose exact point size scales with Dynamic Type
/// (`@ScaledMetric` relative to the token's text style). This is how the design system keeps the
/// mock's precise sizes *and* honors accessibility text sizing — no fixed sizes escape (R4.3).
private struct ScaledFont: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight

    init(token: TypographyToken) {
        _size = ScaledMetric(wrappedValue: token.size, relativeTo: token.relativeTo)
        weight = token.weight
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight))
    }
}

public extension View {
    /// Renders text in the given typography token, scaling with Dynamic Type.
    func medalFont(_ token: TypographyToken) -> some View {
        modifier(ScaledFont(token: token))
    }
}
