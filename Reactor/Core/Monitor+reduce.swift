import Foundation

func accumulateCheck(input: Pulse, accumulator: Pulse) {
    if input.terminal {
        guard accumulator.terminal else { fatalError() }
    }
}

extension Monitor {
    fileprivate func reduceImpl<ResultMonitorType: Monitor>(initial: ResultMonitorType.PayloadType, _ aggregate: @escaping (PayloadType, ResultMonitorType.PayloadType) -> ResultMonitorType.PayloadType, factory: (Transport<ResultMonitorType.PayloadType>) -> ResultMonitorType) -> ResultMonitorType {
        let transport = Transport<ResultMonitorType.PayloadType>()
        let monitor = factory(transport)
        
        var accumulator = initial
        self.observe { payload in
            accumulator = aggregate(payload, accumulator)
            accumulateCheck(input: payload, accumulator: accumulator)
            transport.send(accumulator)
        }
        
        return monitor
    }
    
    func reduce<Accumulator>(initial: Accumulator, _ aggregate: @escaping (PayloadType, Accumulator) -> Accumulator) -> DiscreteMonitor<Accumulator> {
        return reduceImpl(initial: initial, aggregate, factory: { transport in
            return DiscreteMonitor<Accumulator>.create(attachedTo: transport)
        })
    }
}

extension ContinuousMonitor {
    func reduce<Accumulator>(initial: Accumulator, _ aggregate: @escaping (PayloadType, Accumulator) -> Accumulator) -> ContinuousMonitor<Accumulator> {
        return reduceImpl(initial: initial, aggregate, factory: { transport in
            return ContinuousMonitor<Accumulator>.create(attachedTo: transport, initialValue: initial)
        })
    }
}
