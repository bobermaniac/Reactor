import Foundation

private func fmapCheck(input: Pulse, output: Pulse) {
    if input.terminal {
        guard output.terminal else { fatalError() }
    }
}

extension Monitor {
    fileprivate func fmapImpl<ResultMonitorType: Monitor>(_ transform: @escaping (PayloadType) -> ResultMonitorType.PayloadType, factory: (Transport<ResultMonitorType.PayloadType>) -> ResultMonitorType) -> ResultMonitorType {
        let transport = Transport<ResultMonitorType.PayloadType>()
        let monitor = factory(transport)
        
        self.observe { payload in
            let tr = transform(payload)
            fmapCheck(input: payload, output: tr)
            transport.send(tr)
        }
        
        return monitor
    }
    
    func fmap<ResultType>(_ transform: @escaping (PayloadType) -> ResultType) -> DiscreteMonitor<ResultType> {
        return fmapImpl(transform, factory: { transport in
            return DiscreteMonitor<ResultType>.create(attachedTo: transport)
        })
    }
}

extension ContinuousMonitor {
    func fmap<ResultType>(_ transform: @escaping (Payload) -> ResultType) -> ContinuousMonitor<ResultType> {
        let initialValue = transform(self.value)
        return fmapImpl(transform, factory: { transport in
            return ContinuousMonitor<ResultType>.create(attachedTo: transport, initialValue: initialValue)
        })
    }
}
