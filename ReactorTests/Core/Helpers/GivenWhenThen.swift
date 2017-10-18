//
//  GivenWhenThen.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 17/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import Foundation
import XCTest

extension XCTestCase {
    @inline(__always)
    func given(_ block: () -> Void) {
        block()
    }
    @inline(__always)
    func when(_ block: () -> Void) {
        block()
    }
    @inline(__always)
    func then(_ block: () -> Void) {
        block()
    }
}
