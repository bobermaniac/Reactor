import Foundation

public struct SafetyValveTransfererFactory<T: SafetyStrategy> : TransfererFactory {
    public typealias TransferStrategyType = SafetyValveTransferer<T>
    
    public init(mergeQueue: DispatchQueue, strategy: T) {
        _mergeQueue = mergeQueue
        _strategy = strategy
    }
    
    public func create(destination: Pipeline<TransferStrategyType.PulseType>) -> TransferStrategyType {
        return SafetyValveTransferer(destination: destination, safetyStrategy: _strategy, mergeQueue: _mergeQueue)
    }
    
    private let _mergeQueue: DispatchQueue
    private let _strategy: T
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
