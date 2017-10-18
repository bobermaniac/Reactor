//
//  DiscreteSignal.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 15/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
import Reactor

class ContinuousSignalTests: XCTestCase {
    public let initialPulse = IntPulse(integerLiteral: 10)
    private var emitter: ContinuousSignalEmitter<IntPulse>! = nil
    
    override func setUp() {
        super.setUp()
        emitter = ContinuousSignalEmitter(initialValue: initialPulse)
    }
    
    override func tearDown() {
        emitter.emit(0)
        super.tearDown()
    }
    
    func testContainsInitialPulseAtStart() {
        XCTAssertEqual(emitter.monitor.value, initialPulse)
    }
    
    func testInitialPayloadTransfersToObserver() {
        let observer = SignalObserver<IntPulse>()
        given {

        }
        when {
            observer.attach(to: emitter)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialPulse ])
        }
    }
    
    func testEmittedPayloadImmediatelyTransferedToObserver() {
        let observer = SignalObserver<IntPulse>()
        given {
            observer.attach(to: emitter)
        }
        when {
            emitter.emit(1)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialPulse, 1 ])
        }
    }
    
    func testSignalChangesValueAfterEmitting() {
        given {
            
        }
        when {
            emitter.emit(1)
        }
        then {
            XCTAssertEqual(emitter.monitor.value, 1)
        }
    }
    
    func testAllObserversReceivesAllSamePulses() {
        let firstObserver = SignalObserver<IntPulse>()
        let secondObserver = SignalObserver<IntPulse>()
        given {
            firstObserver.attach(to: emitter)
            secondObserver.attach(to: emitter)
        }
        when {
            emitter.emit(1)
        }
        then {
            XCTAssertEqual(firstObserver.pulses, secondObserver.pulses)
        }
    }
    
    func testSignalDetachItsSubscribersOnObsoletePulse() {
        let observer = SignalObserver<IntPulse>()
        given {
            observer.attach(to: emitter)
        }
        when {
            emitter.emit(0)
            emitter.emit(5)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialPulse, 0 ])
        }
    }
    
    func testSignalValueDoesNotChangeAfterObsoletePulse() {
        given {
            
        }
        when {
            emitter.emit(0)
            emitter.emit(5)
        }
        then {
            XCTAssertEqual(emitter.monitor.value, 0)
        }
    }
    
    func testObserverReceivesObsoletePulseOnSubscription() {
        let observer = SignalObserver<IntPulse>()
        given {
            emitter.emit(0)
        }
        when {
            observer.attach(to: emitter)
        }
        then {
            XCTAssertEqual(observer.pulses, [ 0 ])
        }
    }
    
    func testObserverReceivesLastNonObsoletePulseOnSubscription() {
        let observer = SignalObserver<IntPulse>()
        given {
            emitter.emit(5)
        }
        when {
            observer.attach(to: emitter)
        }
        then {
            XCTAssertEqual(observer.pulses, [ 5 ])
        }
    }
    
    func testCancelObservingStopsReceivingPulses() {
        let observer = SignalObserver<IntPulse>()
        var subscribtion: Subscription!
        given {
            subscribtion = observer.attach(to: emitter)
            emitter.emit(5)
        }
        when {
            subscribtion.cancel()
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialPulse, 5 ])
        }
    }
}

