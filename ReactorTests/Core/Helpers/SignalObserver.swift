//
//  SignalObserver.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 15/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import Foundation
import Reactor

class SignalObserver<T: Pulse> {
    var pulses: [ T ] = []
    
    @discardableResult
    public func attach<U: Emitting>(to emitter: U) -> Subscription where U.SignalType.PayloadType == T {
        return emitter.monitor.observe { pulse in
            self.pulses.append(pulse)
        }
    }
}
