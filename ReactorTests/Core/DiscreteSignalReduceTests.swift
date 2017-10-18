//
//  DiscreteSignalReduceTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 18/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

class DiscreteSignalReduceTests: XCTestCase {
    private var emitter: DiscreteSignalEmitter<IntPulse>! = nil
    private var collector: ContinuousSignal<IntPulse>! = nil
    private var reducer: Reducer<IntPulse, IntPulse>! = nil
    private var failureHandlerExecuted = false
    private let initialValue = IntPulse(integerLiteral: 100)
    
    override func setUp() {
        super.setUp()
        emitter = DiscreteSignalEmitter()
        reducer = Reducer()
        collector = emitter.monitor.reduce(initial: initialValue, reducer.provideImpl())
        Contract.failureHandler = { _ in self.failureHandlerExecuted = true }
    }
    
    override func tearDown() {
        reducer.output = [ 0 ]
        emitter.emit(0)
        failureHandlerExecuted = false
        super.tearDown()
    }
    
    public func testInitialAggregateResultEqualsToAccumulator() {
        let observer = SignalObserver<IntPulse>()
        given {
        
        }
        when {
            observer.attach(to: collector)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialValue ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    public func testObseringValuesAreProcessingByReducer() {
        given {
            
        }
        when {
            reducer.output = [ 50 ]
            emitter.emit(5)
        }
        then {
            XCTAssertEqual(reducer.input, [ 5 ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    public func testResultingSignalEmitsReducingResult() {
        let observer = SignalObserver<IntPulse>()
        given {
            observer.attach(to: collector)
        }
        when {
            reducer.output = [ 50 ]
            emitter.emit(5)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialValue, 50 ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    public func testAccumulatorIsTransmittedBetweenObservations() {
        given {
            
        }
        when {
            reducer.output = [ 200, 300 ]
            emitter.emit(5)
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(reducer.accumulators, [ initialValue, 200 ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    public func testObsoleteAggregationResultFinalizesObserving() {
        let observer = SignalObserver<IntPulse>()
        given {
            observer.attach(to: collector)
        }
        when {
            reducer.output = [ 0 ]
            emitter.emit(5)
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialValue, 0 ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    public func testReducerGeneratesErrorIfObsoletePayloadReducedToNonObsolete() {
        let observer = SignalObserver<IntPulse>()
        given {
            observer.attach(to: collector)
        }
        when {
            reducer.output = [ 5 ]
            emitter.emit(0)
        }
        then {
            XCTAssertTrue(failureHandlerExecuted)
        }
    }
}
