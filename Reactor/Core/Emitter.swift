import Foundation

class Emitter<ResultMonitor: Monitor> {
    typealias Payload = ResultMonitor.PayloadType
    
    private let transport: Transport<Payload>
    let monitor: ResultMonitor
    
    init(monitorFactory: (Transport<Payload>) -> ResultMonitor) {
        transport = Transport<Payload>()
        monitor = monitorFactory(transport)
    }
    
    func emit(_ payload: Payload) {
        transport.send(payload)
    }
}
