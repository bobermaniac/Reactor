import Foundation

public class ContinuousSignal<Payload: Pulse>: Signal {
    public typealias PayloadType = Payload
    
    private let impl: SignalCore<Payload>
    
    private(set) public var value: Payload
    
    public init(initialValue: Payload) {
        value = initialValue
        if value.obsolete {
            impl = SignalCore(payload: initialValue)
        } else {
            impl = SignalCore()
        }
    }
    
    static func create(attachedTo transport: Pipeline<Payload>, initialValue: Payload) -> ContinuousSignal {
        let monitor = ContinuousSignal(initialValue: initialValue)
        transport.receive = monitor.receive
        return monitor
    }
    
    private func receive(_ payload: Payload) {
        value = payload
        impl.consume(payload)
    }
    
    @discardableResult
    public func observe(with handler: @escaping (Payload) -> Void) -> Subscription {
        let observation = impl.add(observer: handler)
        if !value.obsolete { handler(value) }
        return observation
    }
}

// Copyright (c) 2017 Victor Bryksin <vbryksin@virtualmind.ru>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
