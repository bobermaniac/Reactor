//
//  DiscreteSignal.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 15/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest

@testable
import Reactor

class DiscreteSignalTests: XCTestCase {
    func testEmittedPayloadImmediatelyTransferedToObserver() {
        let assertion = suite.emitterPayloadImmediatelyTransferedToObserver()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    func testAllObserversReceivesAllSamePulses() {
        let assertion = suite.allObserversSeeSimilarPayloadSequences()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    func testSignalDetachItsSubscribersOnObsoletePulse() {
        let assertion = suite.observerDetachedAfterObsoletePulseEmitted()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    func testObserverDoesntReceiveAnySignalAfterObsoletePulseEmitted() {
        let assertion = suite.observerDoesntReceiveAnySignalAfterObsoletePulseEmitted()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    func testObserverReceivesObsoletePulseOnSubscription() {
        let assertion = suite.observerReceiveObsoletePulseOnAttachingIfApplicable()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    func testCancelObservingStopsReceivingPulses() {
        let assertion = suite.observationCancelingStopsReceivingEvent()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    func testObserverDoesNotReceiveNonObsoletePulseOnSubscription() {
        let emitter = DiscreteSignalEmitter<Probe>()
        defer { emitter.emit(.obsolete) }
        emitter.emit(Probe.signals(count: 3))
        let collector = Collector<Probe>.attached(to: emitter)
        XCTAssertEqual(collector.pulses, [],
                       "Observer should not receive non-obsolete pulses emitted before subscription")
    }
    
    private var suite = Acceptance.signal(emitterFactory: DiscreteSignalEmitter<Probe>.init)
}
