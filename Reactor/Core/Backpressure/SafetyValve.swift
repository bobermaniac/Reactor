import Foundation

public class SafetyValve<T: SafetyStrategy> {
    public typealias StrategyType = T
    public typealias PulseType = StrategyType.PulseType
    
    public init(mergeQueue: DispatchQueue, mergeStrategy: StrategyType) {
        _mergeQueue = mergeQueue
        _mergeStrategy = mergeStrategy
        _pulses = []
    }
    
    public func enqueue(_ object: PulseType) {
        _mergeQueue.async { self._syncAppendAndMergeIfNeeded(object) }
    }
    
    public func dequeue() -> PulseType? {
        return _mergeQueue.sync {
            return self._pulses.count > 0 ? self._pulses.remove(at: 0) : nil
        }
    }
    
    private func _syncAppendAndMergeIfNeeded(_ object: PulseType) {
        _pulses.append(object)
        if _mergeStrategy.requiresMerge(forEuqueuedNumberOfPulses: _pulses.count) {
            _pulses = _mergeStrategy.merge(objects: _pulses)
        }
    }
    
    private let _mergeQueue: DispatchQueue
    private let _mergeStrategy: StrategyType
    private var _pulses: [ PulseType ]
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
