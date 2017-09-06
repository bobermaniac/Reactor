import Foundation

class ContinuousMonitor<Payload: Pulse>: Monitor {
    typealias PayloadType = Payload
    
    private let impl = MonitorImpl<Payload>()
    
    private(set) public var value: Payload
    
    init(initialValue: Payload) {
        value = initialValue
    }
    
    static func create(attachedTo transport: Transport<Payload>, initialValue: Payload) -> ContinuousMonitor {
        let monitor = ContinuousMonitor(initialValue: initialValue)
        transport.receiver = monitor.receive
        return monitor
    }
    
    private func receive(_ payload: Payload) {
        value = payload
        impl.consume(payload)
    }
    
    @discardableResult
    func observe(with handler: @escaping (Payload) -> Void) -> Observation {
        let observation = impl.add(observer: handler)
        if !value.terminal { handler(value) }
        return observation
    }
}
