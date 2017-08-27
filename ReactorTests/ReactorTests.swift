//
//  ReactorTests.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 13/07/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import XCTest
@testable import Reactor

enum Result<T> : Pulse {
    case payload(T)
    case error(Error)
    
    var terminal: Bool { return true }
}

enum Event<T>: Pulse, CustomStringConvertible {
    var description: String {
        switch self {
        case .next(let payload):
            return "\(payload)"
        case .depleted:
            return ""
        case .error(_):
            return "#ERROR"
        }
    }
    
    case next(T)
    case depleted
    case error(Error)
    
    var terminal: Bool {
        if case .depleted = self { return true }
        return false
    }
    
    func fmap<U>(_ handler: (T) -> U) -> Event<U> {
        switch self {
        case .next(let payload):
            return .next(handler(payload))
        case .depleted:
            return .depleted
        case .error(let error):
            return .error(error)
        }
    }
    
    func fmap<U>(_ handler: (T) -> Event<U>) -> Event<U> {
        switch self {
        case .next(let payload):
            return handler(payload)
        case .depleted:
            return .depleted
        case .error(let error):
            return .error(error)
        }
    }
}

func fmap<T1, T2, U>(_ left: Event<T1>, _ right: Event<T2>, _ f: (T1, T2) -> U) -> Event<U> {
    return left.fmap { _1 in right.fmap { _2 in f(_1, _2) }}
}

class ReactorTests: XCTestCase {
    struct AnyError : Error {
        
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPromise() {
        let source = Source<Result<Int>>(kind: .instant)
        source.monitor.subscribe { print($0) }
        source.emit(.payload(5))
        source.emit(.payload(10))
    }
    
    func testMutable() {
        let source = Source<Event<Int>>(kind: .instant)
        source.monitor.subscribe { print($0) }
        source.monitor.fmap { p in return p.fmap { $0 * 50 }  }.subscribe { print($0) }
        source.emit(.next(1))
        source.emit(.next(2))
        source.emit(.depleted)
        source.emit(.next(3))
    }
    
    func testContinuous() {
        let source = Source<Event<Int>>(kind: .continuous(.next(0)))
        source.monitor.subscribe { print($0) }
        source.emit(.next(1))
        source.monitor.subscribe { print($0) }
        source.emit(.depleted)
    }
    
    func testTie() {
        let left = Source<Event<Int>>(kind: .instant)
        let right = Source<Event<Int>>(kind: .instant)
        
        let prepare = { (s: Source<Event<Int>>) in
            return s.monitor.warp(to: .continuous(.next(0)))
        }
        
        tie(prepare(left), prepare(right)) {
            return fmap($0, $1) { (_0, _1) in
                return "\(_0) + \(_1) = \(_0 + _1)"
            }
        }!.subscribe { print($0) }
        
        left.emit(.next(5))                 // | 5  | + | ?  |
        right.emit(.next(8))                // | ?  | + | 8  |
        left.emit(.next(-3))                // | -3 | + | ?  |
        left.emit(.next(1))                 // | 1  | + | ?  |
        right.emit(.error(AnyError()))      // | ?  | + | #  |
        left.emit(.next(5))                 // | 5  | + | ?  |
        right.emit(.next(2))                // | ?  | + | 2  |
        left.emit(.depleted)                // |    | + | ?  |
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
