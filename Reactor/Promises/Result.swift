import Foundation

enum Result<T> : Pulse {
    case payload(T)
    case error(Error)
    
    var terminal: Bool {
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
        switch self {
        case let .payload(object):
            return .payload(transform(object))
        case let .error(error):
            return .error(error)
        }
    }
    
    func fail(transform: (Error) -> T) -> Result<T> {
        guard case let .error(error) = self else { return self }
        return .payload(transform(error))
    }
}

func all<T>(_ results: [ Result<T>? ]) -> Result<[ T ]>? {
    let initial = Result<[ T ]>.payload([])
    func reducer(to optionalAccumulator: Result<[ T ]>?, next: Result<T>?) -> Result<[ T ]>? {
        guard let object = next else { return nil }
        guard let accumulator = optionalAccumulator else { return nil }
        guard case .payload(let allPayloads) = accumulator else { return accumulator }
        switch object {
        case .payload(let payload):
            return .payload(allPayloads + [ payload ])
        case .error(let error):
            return .error(error)
        }
    }
    return results.reduce(initial, reducer)
}

func any<T>(_ results: [ Result<T>? ]) -> Result<T>? {
    let initial = Result<T>.error(CompositeError())
    func reducer(to optionalAccumulator: Result<T>?, next: Result<T>?) -> Result<T>? {
        guard let object = next else {
            if let accumulator = optionalAccumulator, case .payload(_) = accumulator {
                return accumulator
            }
            return nil
        }
        switch object {
        case .payload(_):
            return object
        case .error(let error):
            guard let accumulator = optionalAccumulator, case let .error(accumulatedError) = accumulator else { return optionalAccumulator }
            return .error((accumulatedError as! CompositeError).appending(error))
        }
    }
    return results.reduce(initial, reducer)
}
