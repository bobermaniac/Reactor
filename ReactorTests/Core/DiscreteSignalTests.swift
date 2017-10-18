//
//  DiscreteSignal.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 15/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
import Reactor

class DiscreteSignalTests: XCTestCase {
    private var emitter: DiscreteSignalEmitter<IntPulse>! = nil
    
    override func setUp() {
        super.setUp()
        emitter = DiscreteSignalEmitter()
    }
    
    override func tearDown() {
        emitter.emit(0)
        super.tearDown()
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
            XCTAssertEqual(observer.pulses, [ 1 ])
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
            XCTAssertEqual(observer.pulses, [ 0 ])
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
    
    func testObserverDoesNotReceiveNonObsoletePulseOnSubscription() {
        let observer = SignalObserver<IntPulse>()
        given {
            emitter.emit(5)
        }
        when {
            observer.attach(to: emitter)
        }
        then {
            XCTAssertEqual(observer.pulses.count, 0)
        }
    }
    
    func testCancelObservingStopsReceivingPulses() {
        let observer = SignalObserver<IntPulse>()
        var subscription: Subscription!
        given {
            subscription = observer.attach(to: emitter)
            emitter.emit(5)
        }
        when {
            subscription.cancel()
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(observer.pulses, [ 5 ])
        }
    }
}
