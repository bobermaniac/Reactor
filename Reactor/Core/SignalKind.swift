import Foundation

public enum SignalKind<T> {
    case intermittent
    case continuous(initial: T)
}
