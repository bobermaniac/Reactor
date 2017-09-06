import Foundation

class Promise<T> {
    private let emitter: Emitter<ContinuousSignal<Result<T>>>
    public let future: Future<T>
    
    init() {
        emitter = Emitter(monitorFactory: { ContinuousSignal.create(attachedTo: $0, initialValue: Result<T>.nothing) })
        future = Future(on: emitter.monitor)
    }
    
    func resolve(_ payload: T) {
        emitter.emit(.payload(payload))
    }
    
    func reject(_ error: Error) {
        emitter.emit(.error(error))
    }
}

class Future<T> {
    fileprivate let monitor: ContinuousSignal<Result<T>>
    
    init(on monitor: ContinuousSignal<Result<T>>) {
        self.monitor = monitor
    }
    
    func resolved(_ handler: @escaping (T) -> Void) {
        monitor.observe { $0.unwrap(handler) }
    }
    
    func rejected(_ handler: @escaping (Error) -> Void) {
        monitor.observe { $0.unwrap(handler) }
    }
    
    func then<U>(_ transform: @escaping (T) -> U) -> Future<U> {
        return Future<U>(on: monitor.fmap { $0.fmap(transform) })
    }
    
    func handle(_ transform: @escaping (Error) -> T) -> Future<T> {
        return Future<T>(on: monitor.fmap { $0.fail(transform: transform) })
    }
}

func all<T>(_ futures: [ Future<T> ]) -> Future<[ T ]> {
    return Future(on: tie(futures.map { $0.monitor }, all))
}

func any<T>(_ futures: [ Future<T> ]) -> Future<T> {
    return Future(on: tie(futures.map { $0.monitor }, any))
}
