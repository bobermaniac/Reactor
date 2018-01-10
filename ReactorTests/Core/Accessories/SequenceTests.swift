//
//  SequenceTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 15/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
import Reactor

class SequenceTests: XCTestCase {
    func testAnyResultIsTrueIfAnyOfSequenceSatisfiesCondition() {
        let sequence = [ 1, 2, 3 ]
        XCTAssertTrue(sequence.any { $0 == 1 })
    }
    
    func testAnyResultIsFalseIfNoneOfSequenceSatisfiesCondition() {
        let sequence = [ 1, 2, 3 ]
        XCTAssertFalse(sequence.any { $0 < 0 })
    }
    
    func testAnyResultCalculatingTillFirstSatisfiedCondition() {
        let infiniteSequence = sequence(first: 1, next: { $0 + 1 })
        XCTAssertTrue(infiniteSequence.any { $0 == 1 })
    }
    
    func testAllResultIsTrueIfAllOfSequenceSatisfiesCondition() {
        let sequence = [ 1, 2, 3 ]
        XCTAssertTrue(sequence.all { $0 > 0 })
    }
    
    func testAllResultIsFalseIfAtLeaseOneOfSequenceDoesNotSatifsyCondition() {
        let sequence = [ 1, 2, 3 ]
        XCTAssertFalse(sequence.all { $0 != 3 })
    }
    
    func testAllResultCalculatingTillFirstFailedCondition() {
        let infiniteSequence = sequence(first: 1, next: { $0 + 1 })
        XCTAssertFalse(infiniteSequence.all { $0 != 1 })
    }
}
