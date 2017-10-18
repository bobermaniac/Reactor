//
//  Contracts.swift
//  Reactor
//
//  Created by Victor Bryksin on 16/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import Foundation

struct Contract {
    private init() { }
    
    static var failureHandler: (String) -> Void = defaultFailureHandler
    static func defaultFailureHandler(_ message: String) {
        fatalError(message)
    }
    
    @inline(__always)
    public static func verify(_ condition: Bool, failureMessage: String) {
        if !condition { failureHandler(failureMessage) }
    }
}
