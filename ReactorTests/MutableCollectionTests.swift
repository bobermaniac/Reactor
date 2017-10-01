import XCTest
@testable import Reactor

extension Optional : Pulse {
    public var obsolete: Bool {
        return self == nil
    }
}

class MutableCollectionTests: XCTestCase {
    func testAddingSingleElementToCollection() {
        let collection = Reactor.MutableCollection<Int>()
        let capturer = capture(collection)
        
        collection.append(1)
        let events = capturer.value!
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].events.count, 1)
        assertAdded(event: events[0].events[0], value: 1, index: 0)
    }
    
    func testRemovingSingleElementFromCollection() {
        let collection = Reactor.MutableCollection<Int>(initial: [ 5 ])
        let capturer = capture(collection)
        
        collection.remove(at: 0)
        let events = capturer.value!
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].events.count, 1)
        assertRemoved(event: events[0].events[0], value: 5, index: 0)
    }
    
    func testReplacingSingleElementInCollection() {
        let collection = Reactor.MutableCollection<Int>(initial: [ 5 ])
        let capturer = capture(collection)
        
        collection[0] = 10
        let events = capturer.value!
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].events.count, 1)
        assertReplaced(event: events[0].events[0], old: 5, new: 10, index: 0)
    }
    
    func testSimpleBatchUpdate() {
        let collection = Reactor.MutableCollection<Int>(initial: [ 5, 6, 7, 8, 9 ])
        let capturer = capture(collection)
        
        collection.batchUpdate {
            collection.remove(at: 1)
            collection.remove(at: 0)
            collection[0] = 10
            collection.append(11)
            collection.append(12)
        }
        let events = capturer.value!
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].events.count, 5)
        assertRemoved(event: events[0].events[0], value: 6, index: 1)
        assertRemoved(event: events[0].events[1], value: 5, index: 0)
        assertReplaced(event: events[0].events[2], old: 7, new: 10, index: 0)
        assertAdded(event: events[0].events[3], value: 11, index: 3)
        assertAdded(event: events[0].events[4], value: 12, index: 4)
    }
    
    func testAddRemoveBatchUpdateCollapseToNothing() {
        let collection = Reactor.MutableCollection<Int>()
        let capturer = capture(collection)
        
        collection.batchUpdate {
            collection.append(1)
            collection.remove(at: 0)
        }
        
        let events = capturer.value!
        XCTAssertEqual(events.count, 0)
    }
    
    func testRemoveAddBatchUpdateCollapseToReplace() {
        let collection = Reactor.MutableCollection<Int>(initial: [ 5 ])
        let capturer = capture(collection)
        
        collection.batchUpdate {
            collection.remove(at: 0)
            collection.append(7)
        }
        
        let events = capturer.value!
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].events.count, 1)
        assertReplaced(event: events[0].events[0], old: 5, new: 7, index: 0)
    }
    
    func testMultipleRemoveOperation() {
        let collection = Reactor.MutableCollection<Int>(initial: [ 5, 6, 7, 8 ])
        let capturer = capture(collection)
        
        collection.batchUpdate {
            collection.remove(at: 0)
            collection.remove(at: 0)
            collection.remove(at: 0)
        }
        
        let events = capturer.value!
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].events.count, 3)
        assertRemoved(event: events[0].events[0], value: 7, index: 2)
        assertRemoved(event: events[0].events[1], value: 6, index: 1)
        assertRemoved(event: events[0].events[2], value: 5, index: 0)
    }
    
    func testAppendUpdate() {
        let collection = Reactor.MutableCollection<Int>(initial: [])
        let capturer = capture(collection)
        
        collection.batchUpdate {
            collection.append(1)
            collection[0] = 5
        }
        
        let events = capturer.value!
    }
    
    func testAllMutableCollection() {
        let collection = Reactor.MutableCollection<Int>(initial: [ 5, 6, 7, 8 ])
        let capturer = capture(collection)
        
        collection.batchUpdate {
            collection.append(99)
            collection.insert(45, at: 0)
            collection.remove(at: 3)
            collection.remove(at: 2)
            collection.append(25)
            collection[2] = 71
            collection.remove(at: 2)
            collection[3] = 92
        }
        
        let events = capturer.value!
        XCTAssertEqual(events.count, 1)
        
        var reference = [ 5, 6, 7, 8 ]
        events[0].events.forEach {
            $0.apply(array: &reference)
        }
        XCTAssertEqual(collection.unwrap(), reference)
    }
}

private func capture<T>(_ collection: Reactor.MutableCollection<T>) -> ContinuousSignal<[ Reactor.CollectionEventBatch<T> ]?> {
    let accumulator: [ Reactor.CollectionEventBatch<T> ]? = []
    return collection.obserable.reduce(initial: accumulator) { (batch, acc) in
        if batch.obsolete { return nil }
        return acc! + [ batch ]
    }
}

private func assertAdded<T: Equatable>(event: CollectionEvent<T>, value: T, index: Int) {
    guard case .added = event.kind else {
        XCTFail("Invalid event type, should be `added`")
        return
    }
    XCTAssertEqual(event.payload, value)
    XCTAssertEqual(event.index, index)
}

private func assertRemoved<T: Equatable>(event: CollectionEvent<T>, value: T, index: Int) {
    guard case .removed = event.kind else {
        XCTFail("Invalid event type, should be `removed`")
        return
    }
    XCTAssertEqual(event.payload, value)
    XCTAssertEqual(event.index, index)
}

private func assertReplaced<T: Equatable>(event: CollectionEvent<T>, old: T, new: T, index: Int) {
    guard case let .updated(previous) = event.kind else {
        XCTFail("Invalid event type, should be `replaced`")
        return
    }
    XCTAssertEqual(previous, old)
    XCTAssertEqual(event.payload, new)
    XCTAssertEqual(event.index, index)
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
