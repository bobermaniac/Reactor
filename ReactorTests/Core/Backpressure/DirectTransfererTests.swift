//
//  DirectTransfererTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 22/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

class DirectTransfererTests: XCTestCase {
    private let targetQueue = DispatchQueue(label: "test.direct.queue")
    private let targetQueueSpecific = DispatchSpecificKey<Void>()
    private var transferer: DirectTransferer<IntPulse>! = nil
    private var target: Pipeline<IntPulse>! = nil
    
    override func setUp() {
        super.setUp()
        targetQueue.setSpecific(key: targetQueueSpecific, value: ())
        target = Pipeline()
        transferer = DirectTransfererFactory().create(destination: target)
    }
    
    override func tearDown() {
        target = nil
        transferer = nil
        super.tearDown()
    }
    
    func testTransferToDestinationQueue() {
        let payload: IntPulse = 20
        
        let transferedToCorrectQueue = expectation(description: "Transfered to correct queue")
        target.receive = { pulse in
            XCTAssertEqual(pulse, payload)
            XCTAssertNotNil(DispatchQueue.getSpecific(key: self.targetQueueSpecific))
            transferedToCorrectQueue.fulfill()
        }
        
        transferer.transfer(pulse: payload, on: targetQueue)
        wait(for: [ transferedToCorrectQueue ], timeout: 1.0)
    }
}
