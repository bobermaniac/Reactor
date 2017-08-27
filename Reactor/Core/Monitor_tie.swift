import Foundation

private func verify(input: [ Pulse? ], output: Pulse?) {
    if input.all( { $0?.terminal ?? false } ) {
        guard (output?.terminal ?? false) else {
            fatalError("Result of terminal mixing should exist and also be terminal")
        }
    }
}

private func guarded<T1: Pulse, T2: Pulse, TResult: Pulse>(_ transform: @escaping (T1?, T2?) -> TResult?) -> ((T1?, T2?) -> TResult?) {
    return { _1, _2 in
        let result = transform(_1, _2)
        verify(input: [_1, _2], output: result)
        return result
    }
}

public func tie<T, TResult>(_ input: [ Monitor<T> ], _ transform: @escaping ([ T ]) -> TResult) -> Monitor<TResult>? {
    let inputState = input.flatMap { $0.current }
    guard inputState.count == input.count else { return nil }
    
    let transport = Transport<TResult>()
    let monitor = Monitor<TResult>(kind: .continuous(initial: transform(inputState))).attached(to: transport)
    
    _ = input.map { (monitor) in
        monitor.subscribe { _ in transport.emit(transform(input.map { $0.current! })) }
    }
    return monitor
}

public func tie<T1, T2, U>(_ left: Monitor<T1>, _ right: Monitor<T2>, _ transform: @escaping (T1, T2) -> U) -> Monitor<U>? {
    guard let lc = left.current else { return nil }
    guard let rc = right.current else { return nil }
    
    let transport = Transport<U>()
    let monitor = Monitor<U>(kind: .continuous(initial: transform(lc, rc))).attached(to: transport)
    
    left.subscribe { transport.emit(transform($0, right.current!)) }
    right.subscribe { transport.emit(transform(left.current!, $0)) }
    
    return monitor
}

public func mix<T1, T2, U>(_ left: Monitor<T1>, _ right: Monitor<T2>, _ transform: @escaping (T1?, T2?) -> U?) -> Monitor<U> {
    let transformGuarded = guarded(transform)
    
    let kind = transformGuarded(left.current, right.current).map { SignalKind<U>.continuous(initial: $0) } ?? SignalKind<U>.intermittent
    
    let transport = Transport<U>()
    let monitor = Monitor<U>(kind: kind).attached(to: transport)
    
    left.subscribe { event in
        if let next = transformGuarded(event, right.current) { transport.emit(next) }
    }
    right.subscribe { event in
        if let next = transformGuarded(left.current, event) { transport.emit(next) }
    }
    
    return monitor
}

public func mix<T, TResult>(all input: [ Monitor<T> ], _ transform: @escaping ([ T? ]) -> TResult?) -> Monitor<TResult> {
    
}

private extension Monitor {
    var current: T? {
        guard case .continuous(let payload) = self.kind else { return nil }
        return payload
    }
}
