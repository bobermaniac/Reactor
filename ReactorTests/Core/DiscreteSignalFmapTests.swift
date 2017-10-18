//
//  DiscreteSignalFmapTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 16/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

class DiscreteSignalFmapTests: XCTestCase {
    private var emitter: DiscreteSignalEmitter<IntPulse>! = nil
    private var collector: DiscreteSignal<IntPulse>! = nil
    private var mapper: Mapper<IntPulse, IntPulse>! = nil
    private var failureHandlerExecuted = false
    
    override func setUp() {
        super.setUp()
        emitter = DiscreteSignalEmitter()
        mapper = Mapper()
        collector = emitter.monitor.fmap(mapper.provideImpl())
        Contract.failureHandler = { _ in self.failureHandlerExecuted = true }
    }
    
    override func tearDown() {
        mapper.output = [ 0 ]
        emitter.emit(0)
        failureHandlerExecuted = false
        super.tearDown()
    }
    
    public func testMapperBlockReceivesEmittedPulses() {
        given {
            
        }
        when {
            mapper.output = [ 50 ]
            emitter.emit(5)
        }
        then {
            XCTAssertEqual(mapper.input, [ 5 ])
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
            XCTAssertEqual(observer.pulses, [ 50 ])
            
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
            XCTAssertEqual(observer.pulses, [ 0 ])
            
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
