//
//  ContinuousSignalFmapTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 17/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

class ContinuousSignalFmapTests: XCTestCase {
    public let initialPulse = IntPulse(integerLiteral: 1)
    public let initialMappedPulse = IntPulse(integerLiteral: -1)
    private var emitter: ContinuousSignalEmitter<IntPulse>! = nil
    private var collector: ContinuousSignal<IntPulse>! = nil
    private var mapper: Mapper<IntPulse, IntPulse>! = nil
    private var failureHandlerExecuted = false
    
    override func setUp() {
        super.setUp()
        emitter = ContinuousSignalEmitter(initialValue: initialPulse)
        mapper = Mapper()
        mapper.output = [ initialMappedPulse ]
        collector = emitter.monitor.fmap(mapper.provideImpl())
        Contract.failureHandler = { _ in self.failureHandlerExecuted = true }
    }
    
    override func tearDown() {
        mapper.output = [ 0 ]
        emitter.emit(0)
        failureHandlerExecuted = false
        super.tearDown()
    }
    
    public func testInitialPulseMapped() {
        let observer = SignalObserver<IntPulse>()
        given {

        }
        when {
            observer.attach(to: collector)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialMappedPulse ])
        }
    }
    
    public func testMapperBlockReceivesEmittedPulses() {
        given {
            
        }
        when {
            mapper.output = [ 50 ]
            emitter.emit(5)
        }
        then {
            XCTAssertEqual(mapper.input, [ initialPulse, 5 ])
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    public func testMapperBlockTransmitsTransformationResult() {
        var observer: SignalObserver<IntPulse>!
        given {
            observer = SignalObserver()
            observer.attach(to: collector)
        }
        when {
            mapper.output = [ 50 ]
            emitter.emit(5)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialMappedPulse, 50 ])
            
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    public func testMapperResultIsObsoleteFinalizeResultSignal() {
        var observer: SignalObserver<IntPulse>!
        given {
            observer = SignalObserver()
            observer.attach(to: collector)
        }
        when {
            mapper.output = [ 0 ]
            emitter.emit(5)
            emitter.emit(10)
        }
        then {
            XCTAssertEqual(observer.pulses, [ initialMappedPulse, 0 ])
            
            XCTAssertFalse(failureHandlerExecuted)
        }
    }
    
    public func testMapperGeneratesErrorIfObsoletePayloadMappedToNonObsolete() {
        var observer: SignalObserver<IntPulse>!
        given {
            observer = SignalObserver()
            observer.attach(to: collector)
        }
        when {
            mapper.output = [ 5 ]
            emitter.emit(0)
        }
        then {
            XCTAssertTrue(failureHandlerExecuted)
        }
    }
}
