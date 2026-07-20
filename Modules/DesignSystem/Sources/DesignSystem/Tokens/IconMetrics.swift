import Foundation

/// Geometry for glyphs DesignSystem draws itself (rule 5: no magic numbers in views).
enum IconMetrics {
    /// Vertical-ellipsis dot diameter/gap at the default content size — tuned against the SF
    /// `ellipsis` dot metrics at `.body` so the drawn glyph is a drop-in for the symbol.
    static let ellipsisDotDiameter: CGFloat = 4
    static let ellipsisDotSpacing: CGFloat = 3
}
