import Foundation

enum ResultC<T> : Pulse {
    case nothing
    case payload(T)
    case error(Error)
    
    var terminal: Bool {
        if case .nothing = self { return false }
        return true
    }
    
    func unwrap(_ receiver: (T) -> Void) {
        guard case let .payload(object) = self else { return }
        receiver(object)
    }
    
    func unwrap(_ receiver: (Error) -> Void) {
        guard case let .error(error) = self else { return }
        receiver(error)
    }
    
    func fmap<U>(_ transform: (T) -> U) -> ResultC<U> {
        guard case let .payload(object) = self else { return cast() }
        return .payload(transform(object))
    }
    
    func cast<U>() -> ResultC<U> {
        switch self {
        case .nothing:
            return .nothing
        case let .error(error):
            return .error(error)
        case let .payload(payload):
            return .payload(payload as! U)
        }
    }
    
    func fail(transform: (Error) -> T) -> ResultC<T> {
        guard case let .error(error) = self else { return self }
        return .payload(transform(error))
    }
    
    static func concat<T>(_ lhs: ResultC<[ T ]>, _ rhs: ResultC<T>) -> ResultC<[ T ]> {
        guard case let .payload(payloads) = lhs else { return lhs }
        guard case let .payload(payload) = rhs else { return rhs.cast() }
        return .payload(payloads + [ payload ])
    }
    
    static func select<T>(_ lhs: ResultC<T>, _ rhs: ResultC<T>) -> ResultC<T> {
        if case .payload(_) = lhs { return lhs }
        if case .error(_) = rhs { return lhs }
        return rhs
    }
}


func all<T>(_ results: [ ResultC<T> ]) -> ResultC<[ T ]> {
    return results.reduce(ResultC<[ T ]>.payload([]), ResultC<T>.concat)
}

struct AllRejected: Error { }

func any<T>(_ results: [ ResultC<T> ]) -> ResultC<T> {
    return results.reduce(.error(AllRejected()), ResultC<T>.select)
}
