//
//  BoolTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 15/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
import Reactor

class BoolTests: XCTestCase {
    func testImplicationIfFalseThenFalse() {
        XCTAssertTrue(false => false)
    }
    
    func testImplicationIfFalseThenTrue() {
        XCTAssertTrue(false => true)
    }
    
    func testImplicationIfTrueThenFalse() {
        XCTAssertFalse(true => false)
    }
    
    func testImplicationIfTrueThenTrue() {
        XCTAssertTrue(true => true)
    }
}
