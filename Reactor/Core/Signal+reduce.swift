import Foundation

func accumulateCheck(input: Pulse, accumulator: Pulse) {
    if input.obsolete {
        guard accumulator.obsolete else { fatalError() }
    }
}

extension Signal {
    fileprivate func reduceImpl<ResultMonitorType: Signal>(initial: ResultMonitorType.PayloadType, _ aggregate: @escaping (PayloadType, ResultMonitorType.PayloadType) -> ResultMonitorType.PayloadType, factory: (Pipeline<ResultMonitorType.PayloadType>) -> ResultMonitorType) -> ResultMonitorType {
        let transport = Pipeline<ResultMonitorType.PayloadType>()
        let monitor = factory(transport)
        
        var accumulator = initial
        self.observe { payload in
            accumulator = aggregate(payload, accumulator)
            accumulateCheck(input: payload, accumulator: accumulator)
            transport.send(accumulator)
        }
        
        return monitor
    }
    
    func reduce<Accumulator>(initial: Accumulator, _ aggregate: @escaping (PayloadType, Accumulator) -> Accumulator) -> DiscreteSignal<Accumulator> {
        return reduceImpl(initial: initial, aggregate, factory: { transport in
            return DiscreteSignal<Accumulator>.create(attachedTo: transport)
        })
    }
}

extension ContinuousSignal {
    func reduce<Accumulator>(initial: Accumulator, _ aggregate: @escaping (PayloadType, Accumulator) -> Accumulator) -> ContinuousSignal<Accumulator> {
        return reduceImpl(initial: initial, aggregate, factory: { transport in
            return ContinuousSignal<Accumulator>.create(attachedTo: transport, initialValue: initial)
        })
    }
}
