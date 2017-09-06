import Foundation

private class TerminalGuard2<Left: Pulse, Right: Pulse> {
    var left: Left?
    var right: Right?
    
    func update(left: Left) -> (Left?, Right?) {
        if left.terminal { self.left = left }
        return (left, self.right)
    }
    
    func update(right: Right) -> (Left?, Right?) {
        if right.terminal { self.right = right }
        return (self.left, right)
    }
}

private class TerminalGuardM<T: Pulse> {
    var content: [ T? ]
    
    init(count: Int) {
        content = [ T? ](repeating: nil, count: count)
    }
    
    func update(_ object: T, at index: Int) -> [ T? ] {
        if object.terminal { content[index] = object }
        return content
    }
}

func mixCheck(input: [ Pulse? ], result: Pulse?) {
    if input.filter({ $0?.terminal ?? false }).count == input.count {
        guard result?.terminal ?? false else { fatalError() }
    }
}

func mix<M1: Monitor, M2: Monitor, Result>(_ monitors: (M1, M2), _ transform: @escaping (M1.PayloadType?, M2.PayloadType?) -> Result?) -> DiscreteMonitor<Result> {
    let transport = Transport<Result>()
    let monitor = DiscreteMonitor.create(attachedTo: transport)
    
    let terminalGuard = TerminalGuard2<M1.PayloadType, M2.PayloadType>()
    let transformAndSend = { (input: (M1.PayloadType?, M2.PayloadType?)) -> Void in
        let output = transform(input.0, input.1)
        mixCheck(input: [ input.0, input.1 ], result: output)
        if let result = output { transport.send(result) }
    }
    
    monitors.0.observe { pulse in
        transformAndSend(terminalGuard.update(left: pulse))
    }
    monitors.1.observe { pulse in
        transformAndSend(terminalGuard.update(right: pulse))
    }
    
    return monitor
}

func mix<M: Monitor, Result>(_ monitors: [ M ], _ transform: @escaping ([ M.PayloadType? ]) -> Result?) -> DiscreteMonitor<Result> {
    let transport = Transport<Result>()
    let monitor = DiscreteMonitor.create(attachedTo: transport)
    
    let terminalGuard = TerminalGuardM<M.PayloadType>(count: monitors.count)
    let transformAndSend = { (input: [ M.PayloadType? ]) -> Void in
        let output = transform(input)
        mixCheck(input: input, result: output)
        if let result = output { transport.send(result) }
    }
    
    monitors.enumerated().forEach { args in
        let (offset, m) = args
        m.observe { pulse in
            transformAndSend(terminalGuard.update(pulse, at: offset))
        }
    }
    
    return monitor
}
