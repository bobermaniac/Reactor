//
//  RingBufferTests.swift
//  ReactorTests
//
//  Created by Виктор Брыксин on 09/01/2018.
//  Copyright © 2018 Victor Bryksin. All rights reserved.
//

import XCTest
import Reactor

class RingBufferTests: XCTestCase {
    func testRingBufferReturnsCorrectCapacity() {
        let buffer = RingBuffer<Void>(capacity: 5)
        XCTAssertEqual(buffer.capacity, 5)
    }
    
    func testRingBufferInitialyEmpty() {
        let buffer = RingBuffer<Void>(capacity: 5)
        XCTAssertTrue(buffer.empty)
    }
    
    func testRingBufferInitialyNotFull() {
        let buffer = RingBuffer<Void>(capacity: 5)
        XCTAssertFalse(buffer.full)
    }
    
    func testRingBufferAddsElements() {
        var buffer = RingBuffer<Int>(capacity: 5)
        buffer.put(1)
        buffer.put(2)
        buffer.put(3)
        XCTAssertEqual(buffer.dump(), [1, 2, 3])
    }
    
    func testRingBufferAddsElementsWithOverflow() {
        var buffer = RingBuffer<Int>(capacity: 3)
        buffer.put(1)
        buffer.put(2)
        buffer.put(3)
        buffer.put(4)
        buffer.put(5)
        XCTAssertEqual(buffer.dump(), [3, 4, 5])
    }
    
    func testRingBufferIsFillWhenAllElementsAdded() {
        var buffer = RingBuffer<Int>(capacity: 3)
        buffer.put(3)
        buffer.put(4)
        buffer.put(5)
        XCTAssertTrue(buffer.full)
    }
    
    func testRingBufferRemovesElements() {
        var buffer = RingBuffer<Int>(capacity: 5)
        buffer.put(1)
        buffer.put(2)
        buffer.put(3)
        XCTAssertEqual(buffer.get(), 1)
        XCTAssertEqual(buffer.get(), 2)
        XCTAssertEqual(buffer.get(), 3)
        XCTAssertNil(buffer.get())
    }
    
    func testRingBufferRemovesElementsWithOverflow() {
        var buffer = RingBuffer<Int>(capacity: 3)
        buffer.put(1)
        buffer.put(2)
        buffer.put(3)
        buffer.put(4)
        buffer.put(5)
        XCTAssertEqual(buffer.get(), 3)
        XCTAssertEqual(buffer.get(), 4)
        XCTAssertEqual(buffer.get(), 5)
        XCTAssertNil(buffer.get())
    }
    
    func testRingBufferBecomesEmptyWhenAllElementsRemoved() {
        var buffer = RingBuffer<Int>(capacity: 3)
        buffer.put(1)
        _ = buffer.get()
        XCTAssertTrue(buffer.empty)
    }
}
