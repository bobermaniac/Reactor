//
//  CollectionEventBatch.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 11/09/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

extension CollectionEvent where T: Equatable {
    func isAdded(at index: IndexType, with payload: T) -> Bool {
        if case .added = kind {
            return self.index == index && self.payload == payload
        }
        return false
    }
    
    func isRemoved(at index: IndexType, with payload: T) -> Bool {
        if case .removed = kind {
            return self.index == index && self.payload == payload
        }
        return false
    }
    
    func isUpdated(at index: IndexType, old: T, new: T) -> Bool {
        if case .updated(let previous) = kind {
            return self.index == index && self.payload == new && previous == old
        }
        return false
    }
}

class CollectionEventBatch: XCTestCase {
    typealias Batch = Reactor.CollectionEventBatch<Int>
    typealias Event = Reactor.CollectionEvent<Int>
    
    func testRemoveTwoElementsWithSameIndex() {
        let array = [ 10, 20 ]
        
        var batch = Batch()
    }
}
