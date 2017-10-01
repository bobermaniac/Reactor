import Foundation

extension Signal {
    fileprivate func _filter<SF: SignalFactory>(_ predicate: @escaping (PayloadType) -> Bool, factory: SF) -> SF.SignalType where PayloadType == SF.SignalType.PayloadType {
        func _checked(input: Pulse, condition: Bool) -> Bool {
            guard input.obsolete => condition else { fatalError() }
            return condition
        }
        let (transport, signal) = factory.createBound()
        
        self.observe { payload in
            if _checked(input: payload, condition: predicate(payload)) {
                transport.receive(payload)
            }
        }
        
        return signal
    }
    
    func filter(_ predicate: @escaping (PayloadType) -> Bool) -> DiscreteSignal<PayloadType> {
        return _filter(predicate, factory: DiscreteSignalFactory())
    }
}

extension ContinuousSignal {
    func filter(initial: PayloadType, _ predicate: @escaping (PayloadType) -> Bool) -> ContinuousSignal<PayloadType> {
        guard predicate(initial) else { fatalError() }
        return _filter(predicate, factory: ContinuousSignalFactory(initialValue: initial))
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
