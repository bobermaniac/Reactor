//
//  PromisesTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 12/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
import Reactor

class PromisesTests: XCTestCase {
    func testExample() {
        let expecation = XCTestExpectation(description: "Future will be fullfilled")
        
        let promise = Promise<Int>()
        let pending = promise.future.then { (value) -> Future<Int> in
            let internalPromise = Promise<Int>()
            DispatchQueue.main.async {
                internalPromise.resolve(value + 5)
            }
            return internalPromise.future
        }
        let pending2 = promise.future.then { $0 + 10 }
        promise.resolve(3)
        all([ pending, pending2] ).resolved { values in
            expecation.fulfill()
        }
        wait(for: [ expecation ], timeout: 10.0)
    }
}
