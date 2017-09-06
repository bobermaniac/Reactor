import Foundation

enum Event<T>: Pulse {
    case changed(T)
    case depleted
    case faulted(Error)
    
    var terminal: Bool {
        if case .changed(_) = self { return false }
        return true
    }
    
    func forceUnwrap() -> T {
        guard case let .changed(value) = self else { fatalError() }
        return value
    }
    
    func fmap<U>(_ transform: (T) -> U) -> Event<U> {
        guard case let .changed(payload) = self else { return cast() }
        return .changed(transform(payload))
    }
    
    func cast<U>() -> Event<U> {
        switch self {
        case let .changed(payload):
            return .changed(payload as! U)
        case .depleted:
            return .depleted
        case let .faulted(error):
            return .faulted(error)
        }
    }
}
func terminal<T1, T2, TResult>(_ left: Event<T1>, _ right: Event<T2>) -> Event<TResult> {
    if left.terminal { return left.cast() }
    if right.terminal { return right.cast() }
    fatalError("None is terminal")
}

func tie<T1, T2, TResult>(_ left: Event<T1>, _ right: Event<T2>, _ transform: (T1, T2) -> TResult) -> Event<TResult> {
    guard case let .changed(leftPayload) = left else { return terminal(left, right) }
    guard case let .changed(rightPayload) = right else { return terminal(left, right) }
    return .changed(transform(leftPayload, rightPayload))
}
