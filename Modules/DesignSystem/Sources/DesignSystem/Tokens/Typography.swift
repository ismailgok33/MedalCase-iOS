/// The mock's annotated sizes as scalable tokens (mock p.3): nav title 16, section title/count 14,
/// medal title/value 12. Applied with `.medalFont(_:)`.
public enum Typography {
    public static let navTitle = TypographyToken(size: 16, relativeTo: .headline, weight: .semibold)
    public static let sectionTitle = TypographyToken(size: 14, relativeTo: .subheadline, weight: .semibold)
    public static let sectionCount = TypographyToken(size: 14, relativeTo: .subheadline, weight: .regular)
    public static let medalTitle = TypographyToken(size: 12, relativeTo: .caption, weight: .semibold)
    public static let medalValue = TypographyToken(size: 12, relativeTo: .caption, weight: .regular)
}
