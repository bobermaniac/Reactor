import Foundation

class DiscreteSignal<Payload: Pulse>: Signal {
    typealias PayloadType = Payload
    
    private let impl = SignalCore<Payload>()
    
    static func create(attachedTo transport: Pipeline<Payload>) -> DiscreteSignal {
        let monitor = DiscreteSignal()
        transport.receiver = monitor.receive
        return monitor
    }
    
    private func receive(_ payload: Payload) {
        impl.consume(payload)
    }
    
    @discardableResult
    func observe(with handler: @escaping (Payload) -> Void) -> Subscription {
        return impl.add(observer: handler)
    }
}
