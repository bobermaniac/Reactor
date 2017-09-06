import Foundation

class PromiseC<T> {
    private let emitter: Emitter<ContinuousMonitor<ResultC<T>>>
    public let future: FutureC<T>
    
    init() {
        emitter = Emitter(monitorFactory: { ContinuousMonitor.create(attachedTo: $0, initialValue: ResultC<T>.nothing) })
        future = FutureC(on: emitter.monitor)
    }
    
    func resolve(_ payload: T) {
        emitter.emit(.payload(payload))
    }
    
    func reject(_ error: Error) {
        emitter.emit(.error(error))
    }
}

class FutureC<T> {
    fileprivate let monitor: ContinuousMonitor<ResultC<T>>
    
    init(on monitor: ContinuousMonitor<ResultC<T>>) {
        self.monitor = monitor
    }
    
    func resolved(_ handler: @escaping (T) -> Void) {
        monitor.observe { $0.unwrap(handler) }
    }
    
    func rejected(_ handler: @escaping (Error) -> Void) {
        monitor.observe { $0.unwrap(handler) }
    }
    
    func then<U>(_ transform: @escaping (T) -> U) -> FutureC<U> {
        return FutureC<U>(on: monitor.fmap { $0.fmap(transform) })
    }
    
    func handle(_ transform: @escaping (Error) -> T) -> FutureC<T> {
        return FutureC<T>(on: monitor.fmap { $0.fail(transform: transform) })
    }
}

func all<T>(_ futures: [ FutureC<T> ]) -> FutureC<[ T ]> {
    return FutureC(on: tie(futures.map { $0.monitor }, all))
}

func any<T>(_ futures: [ FutureC<T> ]) -> FutureC<T> {
    return FutureC(on: tie(futures.map { $0.monitor }, any))
}
