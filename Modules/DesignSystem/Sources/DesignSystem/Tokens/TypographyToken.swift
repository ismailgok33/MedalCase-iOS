import SwiftUI

/// A font specification: an exact point size (from the mock's annotations) paired with the text style
/// it scales *relative to*, so Dynamic Type still enlarges it (L8). Rendered via `.medalFont(_:)`.
public struct TypographyToken: Sendable {
    public let size: CGFloat
    public let relativeTo: Font.TextStyle
    public let weight: Font.Weight

    public init(size: CGFloat, relativeTo: Font.TextStyle, weight: Font.Weight) {
        self.size = size
        self.relativeTo = relativeTo
        self.weight = weight
    }
}
