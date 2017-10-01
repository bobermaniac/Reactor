//
//  CollectionEventTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 10/09/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

class CollectionEventSortingTests: XCTestCase {
    typealias Me = CollectionEvent<Int>
    
    func testRemovedRemoved() {
        var events: [ Me ] = []
        events = Me.removed(0, index: 0).bubble(through: events)
        events = Me.removed(1, index: 0).bubble(through: events)
        
        XCTAssertEqual(events.count, 3)
        XCTAssertTrue(events[0].isRemoved(at: 1, with: 1))
        XCTAssertTrue(events[1].isRemoved(at: 0, with: 0))
    }
    
    func testUpdatedRemoved() {
        var events: [ Me ] = []
        events = Me.updated(5, with: 10, index: 5).bubble(through: events)
        events = Me.removed(0, index: 0).bubble(through: events)
        
        XCTAssertEqual(events.count, 2)
        XCTAssertTrue(events[0].isRemoved(at: 0, with: 0))
        XCTAssertTrue(events[1].isUpdated(at: 4, old: 5, new: 10))
    }
    
    func testUpdatedRemovedCollapse() {
        var events: [ Me ] = []
        events = Me.updated(5, with: 10, index: 5).bubble(through: events)
        events = Me.removed(10, index: 5).bubble(through: events)
        
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events[0].isRemoved(at: 5, with: 5))
    }
    
    func testAddedRemoved() {
        var events: [ Me ] = []
        events = Me.added(5, index: 5).bubble(through: events)
        events = Me.removed(0, index: 0).bubble(through: events)
        
        XCTAssertEqual(events.count, 2)
        XCTAssertTrue(events[0].isRemoved(at: 0, with: 0))
        XCTAssertTrue(events[1].isAdded(at: 4, with: 5))
    }
    
    func testAddedRemovedCollapse() {
        var events: [ Me ] = []
        events = Me.added(5, index: 5).bubble(through: events)
        events = Me.removed(5, index: 5).bubble(through: events)
        
        XCTAssertEqual(events.count, 0)
    }
}
