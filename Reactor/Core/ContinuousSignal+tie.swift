import Foundation

func tieCheck(input: [ Pulse ], result: Pulse) {
    if input.first(where: { !$0.obsolete }) != nil {
        guard result.obsolete else { fatalError() }
    }
}

func tie<Left, Right, Result>(_ input: (ContinuousSignal<Left>, ContinuousSignal<Right>), _ transform: @escaping (Left, Right) -> Result) -> ContinuousSignal<Result> {
    let transport = Pipeline<Result>()
    let initial = transform(input.0.value, input.1.value)
    let monitor = ContinuousSignal.create(attachedTo: transport, initialValue: initial)
    
    let transformAndSend: ((Left, Right)) -> Void = { pair in
        let result = transform(pair.0, pair.1)
        tieCheck(input: [ pair.0, pair.1 ], result: result)
        transport.send(result)
    }
    
    input.0.observe { payload in transformAndSend((payload, input.1.value)) }
    input.1.observe { payload in transformAndSend((input.0.value, payload)) }
    
    return monitor
}

func tie<T, Result>(_ input: [ ContinuousSignal<T> ], _ transform: @escaping ([ T ]) -> Result) -> ContinuousSignal<Result> {
    let transport = Pipeline<Result>()
    let initial = transform(input.map { $0.value })
    let monitor = ContinuousSignal.create(attachedTo: transport, initialValue: initial)
    
    let transformAndSend: ([ T ]) -> Void = { input in
        let result = transform(input)
        tieCheck(input: input, result: result)
        transport.send(result)
    }
    
    input.forEach { monitor in
        monitor.observe { payload in transformAndSend(input.map { $0.value }) }
    }
    
    return monitor
}
