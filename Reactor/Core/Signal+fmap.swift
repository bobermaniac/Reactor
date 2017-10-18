import Foundation


public extension Signal {
    fileprivate func _fmap<SF: SignalFactory>(_ transform: @escaping (PayloadType) -> SF.SignalType.PayloadType, factory: SF) -> SF.SignalType {
        let transport = Pipeline<SF.SignalType.PayloadType>()
        self.observe { (payload, subscription) in
            guard !transport.muffed else { return }
            let output = transform(payload)
            Contract.verify(payload.obsolete => output.obsolete, failureMessage: "Obsolete signals should generate obsolete signals")
            transport.receive(output)
            if output.obsolete { subscription.cancel() }
        }
        return factory.create(on: transport)
    }
    
    public func fmap<ResultType>(_ transform: @escaping (PayloadType) -> ResultType) -> DiscreteSignal<ResultType> {
        return _fmap(transform, factory: DiscreteSignalFactory())
    }
}

public extension ContinuousSignal {
    public func fmap<ResultType>(_ transform: @escaping (Payload) -> ResultType) -> ContinuousSignal<ResultType> {
        return _fmap(transform, factory: ContinuousSignalFactory(initialValue: transform(self.value)))
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
