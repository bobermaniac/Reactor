//
//  IntPulse.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 15/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import Foundation
import Reactor

struct IntPulse: Pulse, ExpressibleByIntegerLiteral, Equatable {
    public typealias IntegerLiteralType = Int
    
    public init(_ value: Int) {
        payload = value
    }
    
    public init(integerLiteral value: Int) {
        payload = value
    }
    
    public let payload: Int
    public var obsolete: Bool { return payload == 0 }
    
    public static func ==(_ lhs: IntPulse, _ rhs: IntPulse) -> Bool {
        return lhs.payload == rhs.payload
    }
}
