/// A single medal in the case. `type` and `assetKey` are opaque keys the domain never switches on
/// (forward-compatibility, policies P2/P5); rendering resolves them downstream.
public struct Achievement: Identifiable, Equatable, Sendable {
    public let id: String
    public let type: String
    public let title: String
    public let assetKey: String
    public let status: AchievementStatus

    public init(id: String, type: String, title: String, assetKey: String, status: AchievementStatus) {
        self.id = id
        self.type = type
        self.title = title
        self.assetKey = assetKey
        self.status = status
    }

    /// True when the medal has been earned (regardless of whether it carries a value).
    public var isEarned: Bool {
        if case .earned = status { return true }
        return false
    }
}
