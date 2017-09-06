import Foundation

private func filterCheck(input: Pulse, output: Bool) {
    if input.obsolete {
        guard output else { fatalError() }
    }
}

extension Signal {
    fileprivate func filterImpl<ResultMonitorType: Signal>(_ predicate: @escaping (PayloadType) -> Bool, factory: (Pipeline<PayloadType>) -> ResultMonitorType) -> ResultMonitorType where PayloadType == ResultMonitorType.PayloadType {
        let transport = Pipeline<Self.PayloadType>()
        let monitor = factory(transport)
        
        self.observe { payload in
            let shouldEmit = predicate(payload)
            filterCheck(input: payload, output: shouldEmit)
            if shouldEmit { transport.send(payload) }
        }
        
        return monitor
    }
    
    func filter(_ predicate: @escaping (PayloadType) -> Bool) -> DiscreteSignal<PayloadType> {
        return filterImpl(predicate, factory: { transport in
            return DiscreteSignal<PayloadType>.create(attachedTo: transport)
        })
    }
}

extension ContinuousSignal {
    func filter(_ predicate: @escaping (PayloadType) -> Bool) -> ContinuousSignal<PayloadType> {
        guard predicate(self.value) else { fatalError() }
        return filterImpl(predicate, factory: { transport in
            return ContinuousSignal<PayloadType>.create(attachedTo: transport, initialValue: self.value)
        })
    }
}
