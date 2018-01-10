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

class ContinuousSignalTests: XCTestCase {
    func testContainsInitialPulseAtStart() {
        let emitter = ContinuousSignalEmitter(initialValue: initialProbe)
        
        XCTAssertEqual(emitter.monitor.value, initialProbe)
    }
    
    func testInitialPayloadTransfersToObserver() {
        let emitter = ContinuousSignalEmitter(initialValue: initialProbe)
        let collector = Collector<Probe>.attached(to: emitter)
        XCTAssertEqual(collector.pulses, [ initialProbe ])
    }
    
    func testEmittedPayloadImmediatelyTransferedToObserver() {
        let assertion = suite.emitterPayloadImmediatelyTransferedToObserver()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    func testSignalChangesValueAfterEmitting() {
        let emitter = ContinuousSignalEmitter(initialValue: initialProbe)
        let nextProbe = Probe.signal()
        emitter.emit(nextProbe)
        XCTAssertEqual(emitter.monitor.value, nextProbe)
    }
    
    func testAllObserversReceivesAllSamePulses() {
        let assertion = suite.allObserversSeeSimilarPayloadSequences()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    func testSignalDetachItsSubscribersOnObsoletePulse() {
        let assertion = suite.observerDetachedAfterObsoletePulseEmitted()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    func testSignalValueDoesNotChangeAfterObsoletePulse() {
        let emitter = ContinuousSignalEmitter(initialValue: initialProbe)
        emitter.emit(.obsolete)
        emitter.emit(.signal())
        XCTAssertEqual(emitter.monitor.value, .obsolete)
    }
    
    func testObserverReceivesObsoletePulseOnSubscription() {
        let assertion = suite.observerReceiveObsoletePulseOnAttachingIfApplicable()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    func testObserverReceivesLastNonObsoletePulseOnSubscription() {
        let emitter = ContinuousSignalEmitter(initialValue: initialProbe)
        let nextProbe = Probe.signal()
        emitter.emit(nextProbe)
        let collector = Collector<Probe>.attached(to: emitter)
        XCTAssertEqual(collector.pulses, [ nextProbe ])
    }
    
    func testCancelObservingStopsReceivingPulses() {
        let assertion = suite.observationCancelingStopsReceivingEvent()
        XCTAssertEqual(assertion.expected, assertion.actual, assertion.description)
    }
    
    private var initialProbe: Probe { return state.0 }
    private var suite: SignalAcceptance<ContinuousSignalEmitter<Probe>> { return state.1 }
    private let state = ContinuousSignalTests.makeInitialState()
    
    private static func makeInitialState() -> (Probe, SignalAcceptance<ContinuousSignalEmitter<Probe>>) {
        let probe = Probe.signal()
        let suite = Acceptance.signal(emitterFactory: { ContinuousSignalEmitter(initialValue: probe) })
        return (probe, suite)
    }
}

