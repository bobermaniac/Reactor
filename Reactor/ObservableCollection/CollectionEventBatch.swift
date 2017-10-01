import Foundation

public struct CollectionEventBatch<T> : Pulse, CustomDebugStringConvertible {
    public let obsolete: Bool
    public let events: [ CollectionEvent<T> ]
    
    static func finished() -> CollectionEventBatch<T> {
        return CollectionEventBatch<T>()
    }
    
    static func removed(_ old: T, at index: Int) -> CollectionEventBatch<T> {
        return CollectionEventBatch(batch: [ CollectionEvent<T>.removed(old, index: index) ])
    }
    
    static func replaced(_ old: T, with new: T, at index: Int) -> CollectionEventBatch<T> {
        return CollectionEventBatch(batch: [ CollectionEvent<T>.updated(old, with: new, index: index) ])
    }
    
    static func added(_ value: T, at index: Int) -> CollectionEventBatch<T> {
        return CollectionEventBatch(batch: [ CollectionEvent<T>.added(value, index: index) ])
    }
    
    init(batch: [ CollectionEvent<T> ] = []) {
        obsolete = false
        events = batch
    }
    
    private init(obsolete: Bool) {
        self.obsolete = obsolete
        events = []
    }
    
    private init(copyOf: CollectionEventBatch<T>) {
        obsolete = copyOf.obsolete
        events = copyOf.events
    }
    
    func concatenated(with batch: CollectionEventBatch<T>) -> CollectionEventBatch<T> {
        return batch.events.reduce(self, { $0.concatenated(with: $1) })
    }
    
    func concatenated(with event: CollectionEvent<T>) -> CollectionEventBatch<T> {
        return CollectionEventBatch<T>(batch: event.bubble(through: events))
    }
    
    public var debugDescription: String {
        return events.reduce("Events ", { (s, e) in s + "\(e.debugDescription)\n"  })
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
