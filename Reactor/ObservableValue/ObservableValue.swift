import Foundation

protocol SupportsLogicalOperations {
    static func and(_ lhs: Self, _ rhs: Self) -> Self
    static func or(_ lhs: Self, _ rhs: Self) -> Self
    static func not(_ param: Self) -> Self
}

extension Bool: SupportsLogicalOperations {
    static func not(_ param: Bool) -> Bool {
        return !param
    }
    
    static func and(_ lhs: Bool, _ rhs: Bool) -> Bool {
        return lhs && rhs
    }
    
    static func or(_ lhs: Bool, _ rhs: Bool) -> Bool {
        return lhs || rhs
    }
}

class ObservableValue<T> {
    fileprivate let monitor: ContinuousSignal<Event<T>>
    
    init(on monitor: ContinuousSignal<Event<T>>) {
        self.monitor = monitor
    }
    
    func subscribe(onChange handler: @escaping (Event<T>) -> Void) -> Subscription {
        return monitor.observe(with: handler)
    }
}

func &&<T>(_ lhs: ObservableValue<T>, _ rhs: ObservableValue<T>) -> ObservableValue<T> where T: SupportsLogicalOperations {
    return ObservableValue(on: tie((lhs.monitor, rhs.monitor), { tie($0, $1, T.and) }))
}

func ||<T>(_ lhs: ObservableValue<T>, _ rhs: ObservableValue<T>) -> ObservableValue<T> where T: SupportsLogicalOperations {
    return ObservableValue(on: tie((lhs.monitor, rhs.monitor), { tie($0, $1, T.or) }))
}

prefix func !<T>(_ observable: ObservableValue<T>) -> ObservableValue<T> where T: SupportsLogicalOperations {
    return ObservableValue(on: observable.monitor.fmap { $0.fmap(T.not) })
}
