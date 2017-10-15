import Foundation

public extension Signal {
    fileprivate func id(_ payload: PayloadType) -> PayloadType {
        return payload
    }
    
    fileprivate func extend<SF: SignalFactory>(intermediateTransform: @escaping (PayloadType) -> SF.SignalType.PayloadType, finalTransform: @escaping (PayloadType) -> SF.SignalType, factory: SF) -> SF.SignalType {
        let (transport, signal) = factory.createBound()
        observe { pulse in
            if !pulse.obsolete { transport.receive(intermediateTransform(pulse)) }
            else {
                finalTransform(pulse).observe(with: transport.receive)
            }
        }
        return signal
    }
    
    public func extend<U>(intermediateTransform: @escaping (PayloadType) -> U, finalTransform: @escaping (PayloadType) -> DiscreteSignal<U>) -> DiscreteSignal<U> {
        return extend(intermediateTransform: intermediateTransform, finalTransform: finalTransform, factory: DiscreteSignalFactory())
    }
    
    public func extend<U>(intermediate value: @autoclosure @escaping () -> U, finalTransform: @escaping (PayloadType) -> DiscreteSignal<U>) -> DiscreteSignal<U> {
        return extend(intermediateTransform: { _ in value() }, finalTransform: finalTransform, factory: DiscreteSignalFactory())
    }
    
    public func extend(with signalFactory: @escaping (PayloadType) -> DiscreteSignal<PayloadType>) -> DiscreteSignal<PayloadType> {
        return extend(intermediateTransform: id, finalTransform: signalFactory)
    }
}

public extension ContinuousSignal {
    public func extend<U>(intermediateTransform: @escaping (PayloadType) -> U, finalTransform: @escaping (PayloadType) -> ContinuousSignal<U>) -> ContinuousSignal<U> {
        guard !value.obsolete else { return finalTransform(value) }
        return extend(intermediateTransform: intermediateTransform, finalTransform: finalTransform, factory: ContinuousSignalFactory(initialValue: intermediateTransform(value)))
    }
    
    public func extend<U>(intermediate value: @autoclosure @escaping () -> U, finalTransform: @escaping (PayloadType) -> ContinuousSignal<U>) -> ContinuousSignal<U> {
        return extend(intermediateTransform: { _ in value() }, finalTransform: finalTransform, factory: ContinuousSignalFactory(initialValue: value()))
    }
    
    public func extend(with signalFactory: @escaping (PayloadType) -> ContinuousSignal<PayloadType>) -> ContinuousSignal<PayloadType> {
        return extend(intermediateTransform: id, finalTransform: signalFactory)
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
