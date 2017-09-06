import Foundation

class DiscreteMonitor<Payload: Pulse>: Monitor {
    typealias PayloadType = Payload
    
    private let impl = MonitorImpl<Payload>()
    
    static func create(attachedTo transport: Transport<Payload>) -> DiscreteMonitor {
        let monitor = DiscreteMonitor()
        transport.receiver = monitor.receive
        return monitor
    }
    
    private func receive(_ payload: Payload) {
        impl.consume(payload)
    }
    
    @discardableResult
    func observe(with handler: @escaping (Payload) -> Void) -> Observation {
        return impl.add(observer: handler)
    }
}
