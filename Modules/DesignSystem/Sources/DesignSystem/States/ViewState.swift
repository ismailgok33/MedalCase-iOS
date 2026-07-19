/// The state every async screen drives: loading → loaded / empty / error, each with its own surface.
/// No silent failure, no infinite spinner (CLAUDE.md). Domain-agnostic; the feature supplies `Value`.
public enum ViewState<Value: Equatable & Sendable>: Equatable, Sendable {
    case loading
    case loaded(Value)
    case empty
    case error(UserFacingError)
}
