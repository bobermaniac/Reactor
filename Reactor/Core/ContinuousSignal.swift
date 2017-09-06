import Foundation

class ContinuousSignal<Payload: Pulse>: Signal {
    typealias PayloadType = Payload
    
    private let impl = SignalCore<Payload>()
    
    private(set) public var value: Payload
    
    init(initialValue: Payload) {
        value = initialValue
    }
    
    static func create(attachedTo transport: Pipeline<Payload>, initialValue: Payload) -> ContinuousSignal {
        let monitor = ContinuousSignal(initialValue: initialValue)
        transport.receiver = monitor.receive
        return monitor
    }
    
    private func receive(_ payload: Payload) {
        value = payload
        impl.consume(payload)
    }
    
    @discardableResult
    func observe(with handler: @escaping (Payload) -> Void) -> Subscription {
        let observation = impl.add(observer: handler)
        if !value.obsolete { handler(value) }
        return observation
    }
}
