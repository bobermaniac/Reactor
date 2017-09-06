//
//  ReactorTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 13/07/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

class ReactorTests: XCTestCase {
    struct AnyError : Error {
        
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDiscreteMonitor() {
        let left = MutableValue(initial: true)
        let right = MutableValue(initial: false)
        
        let calculation = !left.observable && right.observable
        let token = calculation.subscribe {
            print($0.forceUnwrap())
        }
        
        right.value = true
        left.value = false
        token.cancel()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
