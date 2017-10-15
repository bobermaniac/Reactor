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
        observer.attach(to: emitter)
        emitter.emit(1)
        XCTAssertEqual(observer.pulses.count, 1)
        XCTAssertEqual(observer.pulses[0], 1)
    }
    
    func testAllObserversReceivesAllSamePulses() {
        let firstObserver = SignalObserver<IntPulse>()
        firstObserver.attach(to: emitter)
        let secondObserver = SignalObserver<IntPulse>()
        secondObserver.attach(to: emitter)
        emitter.emit(1)
        XCTAssertEqual(firstObserver.pulses, secondObserver.pulses)
    }
    
    func testSignalDetachItsSubscribersOnObsoletePulse() {
        let observer = SignalObserver<IntPulse>()
        observer.attach(to: emitter)
        emitter.emit(0)
        emitter.emit(5)
        XCTAssertEqual(observer.pulses.count, 1)
        XCTAssertEqual(observer.pulses[0], 0)
    }
    
    func testObserverReceivesObsoletePulseOnSubscription() {
        emitter.emit(0)
        let observer = SignalObserver<IntPulse>()
        observer.attach(to: emitter)
        XCTAssertEqual(observer.pulses.count, 1)
        XCTAssertEqual(observer.pulses[0], 0)
    }
    
    func testObserverDoesNotReceiveNonObsoletePulseOnSubscription() {
        emitter.emit(5)
        let observer = SignalObserver<IntPulse>()
        observer.attach(to: emitter)
        XCTAssertEqual(observer.pulses.count, 0)
    }
    
    func testCancelObservingStopsReceivingPulses() {
        let observer = SignalObserver<IntPulse>()
        let subscribtion = observer.attach(to: emitter)
        emitter.emit(5)
        subscribtion.cancel()
        emitter.emit(10)
        XCTAssertEqual(observer.pulses.count, 1)
        XCTAssertEqual(observer.pulses[0], 5)
    }
}
