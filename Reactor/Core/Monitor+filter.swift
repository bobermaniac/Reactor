import Foundation

private func filterCheck(input: Pulse, output: Bool) {
    if input.terminal {
        guard output else { fatalError() }
    }
}

extension Monitor {
    fileprivate func filterImpl<ResultMonitorType: Monitor>(_ predicate: @escaping (PayloadType) -> Bool, factory: (Transport<PayloadType>) -> ResultMonitorType) -> ResultMonitorType where PayloadType == ResultMonitorType.PayloadType {
        let transport = Transport<Self.PayloadType>()
        let monitor = factory(transport)
        
        self.observe { payload in
            let shouldEmit = predicate(payload)
            filterCheck(input: payload, output: shouldEmit)
            if shouldEmit { transport.send(payload) }
        }
        
        return monitor
    }
    
    func filter(_ predicate: @escaping (PayloadType) -> Bool) -> DiscreteMonitor<PayloadType> {
        return filterImpl(predicate, factory: { transport in
            return DiscreteMonitor<PayloadType>.create(attachedTo: transport)
        })
    }
}

extension ContinuousMonitor {
    func filter(_ predicate: @escaping (PayloadType) -> Bool) -> ContinuousMonitor<PayloadType> {
        guard predicate(self.value) else { fatalError() }
        return filterImpl(predicate, factory: { transport in
            return ContinuousMonitor<PayloadType>.create(attachedTo: transport, initialValue: self.value)
        })
    }
}
