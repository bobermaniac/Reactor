import Foundation

public class MutableCollection<T> : Sequence, ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = T
    public typealias Iterator = Array<T>.Iterator
    
    private let _emitter: Emitter<DiscreteSignal<CollectionEventBatch<T>>>
    private var _array: [ T ]
    
    public var observable: DiscreteSignal<CollectionEventBatch<T>> {
        return _emitter.monitor
    }
    
    public init(initial array: [ T ] = []) {
        _emitter = Emitter(factory: DiscreteSignalFactory())
        _array = array
    }
    
    public required init(arrayLiteral elements: T...) {
        _emitter = Emitter(factory: DiscreteSignalFactory())
        _array = elements
    }
    
    public func makeIterator() -> MutableCollection<T>.Iterator {
        return _array.makeIterator()
    }
    
    public subscript(index: Int) -> T {
        get {
            return _array[index]
        }
        set {
            let old = _array[index]
            _array[index] = newValue
            _emit(CollectionEventBatch.replaced(old, with: newValue, at: index))
        }
    }
    
    public func append(_ newElement: T) {
        let index = _array.count
        _array.append(newElement)
        _emit(CollectionEventBatch<T>.added(newElement, at: index))
    }
    
    public func append<U: Sequence>(contentsOf sequence: U) where U.Element == T {
        let startIndex = _array.count
        _array.append(contentsOf: sequence)
        let diff = (startIndex..<_array.count).map { CollectionEvent<T>.added(_array[$0], index: $0) }
        _emit(CollectionEventBatch<T>(batch: diff))
    }
    
    public func insert(_ newElement: T, at index: Int) {
        _array.insert(newElement, at: index)
        _emit(CollectionEventBatch<T>.added(newElement, at: index))
    }
    
    public func remove(at index: Int) {
        let value = _array.remove(at: index)
        _emit(CollectionEventBatch<T>.removed(value, at: index))
    }
    
    public func removeAll() {
        let diff = (0..<_array.count).map { CollectionEvent<T>.removed(_array[$0], index: $0) }.reversed() as [ CollectionEvent<T> ]
        _array.removeAll()
        _emit(CollectionEventBatch<T>(batch: diff))
    }
    
    public func batchUpdate(_ updates: () -> Void) {
        _currentUpdateBatch = CollectionEventBatch<T>(batch: [])
        updates()
        let batch = _currentUpdateBatch!
        _currentUpdateBatch = nil
        if (batch.events.count > 0) {
            _emit(batch)
        }
    }
    
    private var _currentUpdateBatch: CollectionEventBatch<T>?
    
    private func _emit(_ event: CollectionEventBatch<T>) {
        guard let batch = _currentUpdateBatch else {
            _emitter.emit(event)
            return
        }
        _currentUpdateBatch = batch.concatenated(with: event)
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
