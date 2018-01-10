import Foundation

public struct RingBuffer<T>: Sequence {
    public typealias Element = T
    public typealias Iterator = RingBufferIterator<T>
    
    public init(capacity: Int) {
        items = [T?](repeating: nil, count: capacity + 1)
    }
    
    public mutating func put(_ object: T) {
        items[head] = object
        head = (head + 1) % items.count
        if head == tail {
            tail = (tail + 1) % items.count
        }
    }
    
    public mutating func get() -> T? {
        if empty {
            return nil
        }
        let result = items[tail]
        tail = (tail + 1) % items.count
        return result
    }
    
    public mutating func reset() {
        items = [T?](repeating: nil, count: items.count)
        head = 0
        tail = 0
    }
    
    public func makeIterator() -> RingBufferIterator<T> {
        return RingBufferIterator(content: dump())
    }
    
    public var capacity: Int {
        return items.count - 1
    }
    
    public var empty: Bool {
        return head == tail
    }
    
    public var full: Bool {
        return (head + 1) % items.count == tail
    }
    
    public func dump() -> [T] {
        if empty {
            return []
        }
        let unwrapedHead = head + (head < tail ? items.count : 0)
        return (tail..<unwrapedHead).map { items[$0 % items.count]! }
    }
    
    private var items: [T?]
    private var head: Int = 0
    private var tail: Int = 0
}

public struct RingBufferIterator<T>: IteratorProtocol {
    public typealias Element = T
    
    init(content: [T]) {
        iterator = content.makeIterator()
    }
    
    public mutating func next() -> T? {
        return iterator.next()
    }
    
    private var iterator: IndexingIterator<[T]>
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
