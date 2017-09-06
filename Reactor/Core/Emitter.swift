import Foundation

class Emitter<ResultMonitor: Signal> {
    typealias Payload = ResultMonitor.PayloadType
    
    private let transport: Pipeline<Payload>
    let monitor: ResultMonitor
    
    init(monitorFactory: (Pipeline<Payload>) -> ResultMonitor) {
        transport = Pipeline<Payload>()
        monitor = monitorFactory(transport)
    }
    
    func emit(_ payload: Payload) {
        transport.send(payload)
    }
}
