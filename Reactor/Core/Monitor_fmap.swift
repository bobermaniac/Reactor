import Foundation

public extension Monitor {
    func fmap<Result>(_ transform: @escaping (T) -> Result) -> Monitor<Result> {
        let transport = Transport<Result>()
        let monitor = Monitor<Result>(kind: self.kind.fmap(transform)).attached(to: transport)
        self.subscribe { transport.emit(transform($0)) }
        return monitor
    }
    
    func filter(_ predicate: @escaping (T) -> Bool) -> Monitor<T> {
        let transport = Transport<T>()
        let monitor = Monitor<T>(kind: self.kind.filter(predicate)).attached(to: transport)
        self.subscribe { event in
            if event.terminal || predicate(event) {
                transport.emit(event)
            }
        }
        return monitor
    }
}

extension Monitor.Kind {
    func fmap<U>(_ transform: (T) -> U) -> Monitor<U>.Kind {
        switch self {
        case .instant:
            return .instant
        case .continuous(let payload):
            return .continuous(transform(payload))
        }
    }
    
    func filter(_ predicate: (T) -> Bool) -> Monitor<T>.Kind {
        guard case .continuous(let payload) = self else { return self }
        guard !payload.terminal else { return self }
        return predicate(payload) ? self : .instant
    }
}
