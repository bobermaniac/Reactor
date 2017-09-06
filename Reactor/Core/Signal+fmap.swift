import Foundation

private func fmapCheck(input: Pulse, output: Pulse) {
    if input.obsolete {
        guard output.obsolete else { fatalError() }
    }
}

extension Signal {
    fileprivate func fmapImpl<ResultMonitorType: Signal>(_ transform: @escaping (PayloadType) -> ResultMonitorType.PayloadType, factory: (Pipeline<ResultMonitorType.PayloadType>) -> ResultMonitorType) -> ResultMonitorType {
        let transport = Pipeline<ResultMonitorType.PayloadType>()
        let monitor = factory(transport)
        
        self.observe { payload in
            let tr = transform(payload)
            fmapCheck(input: payload, output: tr)
            transport.send(tr)
        }
        
        return monitor
    }
    
    func fmap<ResultType>(_ transform: @escaping (PayloadType) -> ResultType) -> DiscreteSignal<ResultType> {
        return fmapImpl(transform, factory: { transport in
            return DiscreteSignal<ResultType>.create(attachedTo: transport)
        })
    }
}

extension ContinuousSignal {
    func fmap<ResultType>(_ transform: @escaping (Payload) -> ResultType) -> ContinuousSignal<ResultType> {
        let initialValue = transform(self.value)
        return fmapImpl(transform, factory: { transport in
            return ContinuousSignal<ResultType>.create(attachedTo: transport, initialValue: initialValue)
        })
    }
}
