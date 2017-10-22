import Foundation

public extension Signal {
    fileprivate func _transfer<SF: SignalFactory, TF: TransfererFactory>(to queue: DispatchQueue, signalFactory: SF, transfererFactory: TF) -> SF.SignalType where SF.SignalType.PayloadType == Self.PayloadType, TF.TransferStrategyType.PulseType == Self.PayloadType {
        let (transport, signal) = signalFactory.createBound()
        let transferer = transfererFactory.create(destination: transport)
        transferer.transfer(from: self, on: queue)
        return signal
    }
    
    public func transfer(to queue: DispatchQueue) -> DiscreteSignal<PayloadType> {
        return _transfer(to: queue, signalFactory: DiscreteSignalFactory(), transfererFactory: DirectTransfererFactory())
    }
    
    public func transfer<SS: SafetyStrategy & MergeQueueProviding>(to queue: DispatchQueue, safetyStrategy: SS) -> DiscreteSignal<PayloadType> where SS.PulseType == PayloadType {
        return transfer(to: queue, safetyStrategy: safetyStrategy, mergeQueue: safetyStrategy.mergeQueue)
    }
    
    public func transfer<SS: SafetyStrategy>(to queue: DispatchQueue, safetyStrategy: SS, mergeQueue: DispatchQueue) -> DiscreteSignal<PayloadType> where SS.PulseType == PayloadType {
        let transferStrategyFactory = SafetyValveTransfererFactory(mergeQueue: mergeQueue, strategy: safetyStrategy)
        return _transfer(to: queue, signalFactory: DiscreteSignalFactory(), transfererFactory: transferStrategyFactory)
    }
}

public extension ContinuousSignal {
    public func transfer(to queue: DispatchQueue) -> ContinuousSignal<PayloadType> {
        return _transfer(to: queue, signalFactory: ContinuousSignalFactory(initialValue: self.value), transfererFactory: DirectTransfererFactory())
    }
    
    public func transfer<SS: SafetyStrategy & MergeQueueProviding>(to queue: DispatchQueue, safetyStrategy: SS) -> ContinuousSignal<PayloadType> where SS.PulseType == PayloadType {
        return transfer(to: queue, safetyStrategy: safetyStrategy, mergeQueue: safetyStrategy.mergeQueue)
    }
    
    public func transfer<SS: SafetyStrategy>(to queue: DispatchQueue, safetyStrategy: SS, mergeQueue: DispatchQueue) -> ContinuousSignal<PayloadType> where SS.PulseType == PayloadType {
        let transferStrategyFactory = SafetyValveTransfererFactory(mergeQueue: mergeQueue, strategy: safetyStrategy)
        return _transfer(to: queue, signalFactory: ContinuousSignalFactory(initialValue: self.value), transfererFactory: transferStrategyFactory)
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
