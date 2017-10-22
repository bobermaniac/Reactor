//
//  ContinuousSignalFilterTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 22/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

class ContinuousSignalFilterTests: XCTestCase {
    private var emitter: ContinuousSignalEmitter<IntPulse>! = nil
    private var collector: ContinuousSignal<IntPulse>! = nil
    private var mapper: Mapper<IntPulse, Bool>! = nil
    private var failureHandlerExecuted = false
    private let initialValue = IntPulse(integerLiteral: 100)
    private let initialFilteredValue = IntPulse(integerLiteral: 500)
    
    override func setUp() {
        super.setUp()
        emitter = ContinuousSignalEmitter(initialValue: initialValue)
        Contract.failureHandler = { _ in self.failureHandlerExecuted = true }
    }
    
    override func tearDown() {
        mapper.output = [ true ]
        emitter.emit(0)
        failureHandlerExecuted = false
        super.tearDown()
    }
    
    private func attachPredicate(initialTransform: Bool = false) {
        mapper = Mapper()
        mapper.output = [ initialTransform ]
        collector = emitter.monitor.filter(initial: initialFilteredValue, mapper.provideImpl())
    }

    func testResultEmitsInitialValueIfSingalValueBecomesFiltered() {
        attachPredicate(initialTransform: false)
        
        XCTAssertEqual(collector.value, initialFilteredValue)
        XCTAssertFalse(failureHandlerExecuted)
    }
    
    func testResultEmitsSameValueIfSingalValueIsNotFiltered() {
        attachPredicate(initialTransform: true)
        
        XCTAssertEqual(collector.value, emitter.monitor.value)
        XCTAssertFalse(failureHandlerExecuted)
    }
    
    func testBlockReceivesAllSignalPayloads() {
        given {
            attachPredicate()
        }
        when {
            mapper.output = [ false ]
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(mapper.input, [ initialValue, 10 ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    func testPulsesSatisfyingConditionAreForwardingToSignal() {
        let observer = SignalObserver<IntPulse>()
        given {
            attachPredicate()
            observer.attach(to: collector)
        }
        when {
            mapper.output = [ true ]
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialFilteredValue, 10 ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    func testPulsesNotSatisfyingConditionAreNotForwardingToSignal() {
        let observer = SignalObserver<IntPulse>()
        given {
            attachPredicate()
            observer.attach(to: collector)
        }
        when {
            mapper.output = [ false ]
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialFilteredValue ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    public func testFilterGeneratesErrorIfObsoletePayloadFiltered() {
        let observer = SignalObserver<IntPulse>()
        given {
            attachPredicate()
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
