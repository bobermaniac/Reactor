//
//  DiscreteSignalFilterTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 19/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

class DiscreteSignalFilterTests: XCTestCase {
    private var emitter: DiscreteSignalEmitter<IntPulse>! = nil
    private var collector: DiscreteSignal<IntPulse>! = nil
    private var mapper: Mapper<IntPulse, Bool>! = nil
    private var failureHandlerExecuted = false
    
    override func setUp() {
        super.setUp()
        emitter = DiscreteSignalEmitter()
        mapper = Mapper()
        collector = emitter.monitor.filter(mapper.provideImpl())
        Contract.failureHandler = { _ in self.failureHandlerExecuted = true }
    }
    
    override func tearDown() {
        mapper.output = [ true ]
        emitter.emit(0)
        failureHandlerExecuted = false
        super.tearDown()
    }
    
    func testBlockReceivesAllSignalPayloads() {
        given {
            
        }
        when {
            mapper.output = [ false ]
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(mapper.input, [ 10 ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    func testPulsesSatisfyingConditionAreForwardingToSignal() {
        let observer = SignalObserver<IntPulse>()
        given {
            observer.attach(to: collector)
        }
        when {
            mapper.output = [ true ]
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(observer.pulses, [ 10 ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    func testPulsesNotSatisfyingConditionAreNotForwardingToSignal() {
        let observer = SignalObserver<IntPulse>()
        given {
            observer.attach(to: collector)
        }
        when {
            mapper.output = [ false ]
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(observer.pulses, [ ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    public func testFilterGeneratesErrorIfObsoletePayloadFiltered() {
        let observer = SignalObserver<IntPulse>()
        given {
            observer.attach(to: collector)
        }
        when {
            mapper.output = [ false ]
            emitter.emit(0)
        }
        then {
            XCTAssertTrue(failureHandlerExecuted)
        }
    }
}
