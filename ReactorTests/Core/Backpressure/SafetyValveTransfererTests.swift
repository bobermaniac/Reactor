//
//  SafetyValveTransfererTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 22/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

class SafetyValveTransfererTests: XCTestCase {
    private var transferer: SafetyValveTransferer<TestSafetyStrategy>! = nil
    private var pipeline: Pipeline<IntPulse>! = nil
    private let mergeQueue = DispatchQueue(label: "test.merge.queue")
    private let mergeQueueSpecific = DispatchSpecificKey<Void>()
    private let targetQueue = DispatchQueue(label: "test.direct.queue")
    private let targetQueueSpecific = DispatchSpecificKey<Void>()
    private let safetyStrategy = TestSafetyStrategy()
    
    override func setUp() {
        super.setUp()
        mergeQueue.setSpecific(key: mergeQueueSpecific, value: ())
        pipeline = Pipeline()
        transferer = SafetyValveTransferer(destination: pipeline, safetyStrategy: safetyStrategy, mergeQueue: mergeQueue)
    }
    
    override func tearDown() {
        pipeline = nil
        transferer = nil
        super.tearDown()
    }
    
    func testCountsPendingPayloadsWhileTargetQueueLocked() {
        let targetQueueLocked = QueueGate.scheduled(on: targetQueue)
        
        var counts: [ Int ] = []
        var mergeQueueMarkersFound: Int = 0
        for p in 1...5 {
            let mergeQueueWaiter = QueueGate(queue: mergeQueue)
            
            var count: Int? = nil
            var queueMarker: Void? = nil
            safetyStrategy.requiresMergeImpl = { c in
                count = c
                queueMarker = DispatchQueue.getSpecific(key: self.mergeQueueSpecific)
                return false
            }
            
            transferer.transfer(pulse: IntPulse(p), on: targetQueue)
            mergeQueueWaiter.wait()
            
            if let c = count { counts.append(c) }
            if queueMarker != nil { mergeQueueMarkersFound += 1 }
        }
        
        targetQueueLocked.passAndWait()
        XCTAssertEqual(counts, [ 1, 2, 3, 4, 5 ])
        XCTAssertEqual(mergeQueueMarkersFound, 5)
    }
    
    func testAppliesMergeStrategyWhenItIsRequired() {
        let targetQueueLocked = QueueGate.scheduled(on: targetQueue)
        let mergeQueueWaiter = QueueGate(queue: mergeQueue)
        
        safetyStrategy.requiresMergeImpl = { _ in return false }
        transferer.transfer(pulse: 1, on: targetQueue)
        safetyStrategy.requiresMergeImpl = { _ in return true }
        var capturedInput: [ IntPulse ]?
        var onMergeQueue = false
        safetyStrategy.mergeImpl = { input in
            capturedInput = input
            onMergeQueue = DispatchQueue.getSpecific(key: self.mergeQueueSpecific) != nil
            return input
        }
        transferer.transfer(pulse: 2, on: targetQueue)
        mergeQueueWaiter.wait()
        
        targetQueueLocked.passAndWait()
        XCTAssertEqual(capturedInput!, [ 1, 2 ])
        XCTAssertTrue(onMergeQueue)
    }
    
    func testTransportReceivesOnlyMergeResultPayloads() {
        let targetQueueLocked = QueueGate.scheduled(on: targetQueue)
        let mergeQueueWaiter = QueueGate(queue: mergeQueue)
        
        safetyStrategy.requiresMergeImpl = { _ in return false }
        safetyStrategy.mergeImpl = { _ in return [ 100, 300, 500 ] }
        (1...9).map(IntPulse.init(integerLiteral:)).forEach { p in
            transferer.transfer(pulse: p, on: targetQueue)
        }
        safetyStrategy.requiresMergeImpl = { _ in return true }
        transferer.transfer(pulse: 10, on: targetQueue)
        mergeQueueWaiter.wait()
        
        var capturedPayloads: [ IntPulse ] = []
        pipeline.receive = { capturedPayloads.append($0) }
        targetQueueLocked.passAndWait()
        
        XCTAssertEqual(capturedPayloads, [ 100, 300, 500 ])
    }
    
    func testNoPayloadCanBeAccessedWhileMerging() {
        let targetQueueLocked = QueueGate.scheduled(on: targetQueue)
        
        safetyStrategy.requiresMergeImpl = { _ in return false }
        safetyStrategy.mergeImpl = { _ in return [ 100 ] }
        transferer.transfer(pulse: 10, on: targetQueue)
        
        let mergeQueueLock = DispatchGroup()
        mergeQueueLock.enter()
        safetyStrategy.requiresMergeImpl = { _ in return true }
        safetyStrategy.mergeImpl = { _ in
            mergeQueueLock.wait()
            return [ 100 ]
        }
        
        var receiveInvoked = false
        pipeline.receive = { _ in receiveInvoked = true }
        targetQueueLocked.pass()
        
        usleep(100000)
        XCTAssertFalse(receiveInvoked)
        mergeQueueLock.leave()
        targetQueueLocked.wait()
    }
}

private class TestSafetyStrategy: SafetyStrategy {
    typealias PulseType = IntPulse
    
    public var mergeImpl: ([ IntPulse ]) -> [ IntPulse ] = { _ in fatalError() }
    public var requiresMergeImpl: (Int) -> Bool = { _ in fatalError()}
    
    func merge(objects: [ IntPulse ]) -> [ IntPulse ] {
        return mergeImpl(objects)
    }
    
    func requiresMerge(forEuqueuedNumberOfPulses numberOfPulses: Int) -> Bool {
        return requiresMergeImpl(numberOfPulses)
    }
}
