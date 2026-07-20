import SwiftUI

/// The mock's bare vertical ellipsis (⋮), drawn as three circles.
///
/// Drawn — not SF Symbols — for two reasons. SF has no bare vertical-ellipsis symbol (only bubbled
/// variants), and the obvious workaround (horizontal `ellipsis` + `rotationEffect`) participates
/// badly in iOS 26's menu-dismiss morph: the system re-renders the source label while the Liquid
/// Glass lens settles, and the transformed symbol vanished to a single dot for ~1.2 s (measured
/// frame-by-frame). Plain geometry gives the morph nothing to animate but a fade.
///
/// Inherits the caller's `foregroundStyle`; dot metrics scale with Dynamic Type like the symbol would.
public struct VerticalEllipsisIcon: View {
    @ScaledMetric(relativeTo: .body) private var dotDiameter = IconMetrics.ellipsisDotDiameter
    @ScaledMetric(relativeTo: .body) private var dotSpacing = IconMetrics.ellipsisDotSpacing

    public init() {}

    public var body: some View {
        VStack(spacing: dotSpacing) {
            dot
            dot
            dot
        }
        .accessibilityHidden(true)
    }

    private var dot: some View {
        Circle().frame(width: dotDiameter, height: dotDiameter)
    }
}

#Preview {
    VerticalEllipsisIcon()
}
