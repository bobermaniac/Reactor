import Foundation

enum Result<T> : Pulse {
    case nothing
    case payload(T)
    case error(Error)
    
    var obsolete: Bool {
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
    
    func fmap<U>(_ transform: (T) -> U) -> Result<U> {
        guard case let .payload(object) = self else { return cast() }
        return .payload(transform(object))
    }
    
    func cast<U>() -> Result<U> {
        switch self {
        case .nothing:
            return .nothing
        case let .error(error):
            return .error(error)
        case let .payload(payload):
            return .payload(payload as! U)
        }
    }
    
    func fail(transform: (Error) -> T) -> Result<T> {
        guard case let .error(error) = self else { return self }
        return .payload(transform(error))
    }
    
    static func concat<T>(_ lhs: Result<[ T ]>, _ rhs: Result<T>) -> Result<[ T ]> {
        guard case let .payload(payloads) = lhs else { return lhs }
        guard case let .payload(payload) = rhs else { return rhs.cast() }
        return .payload(payloads + [ payload ])
    }
    
    static func select<T>(_ lhs: Result<T>, _ rhs: Result<T>) -> Result<T> {
        if case .payload(_) = lhs { return lhs }
        if case .error(_) = rhs { return lhs }
        return rhs
    }
}


func all<T>(_ results: [ Result<T> ]) -> Result<[ T ]> {
    return results.reduce(Result<[ T ]>.payload([]), Result<T>.concat)
}

struct AllRejected: Error { }

func any<T>(_ results: [ Result<T> ]) -> Result<T> {
    return results.reduce(.error(AllRejected()), Result<T>.select)
}
