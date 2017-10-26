//
//  Waiter.swift
//  ReactorTests
//
//  Created by Victor Bryksin on 24/10/2017.
//  Copyright © 2017 Victor Bryksin. All rights reserved.
//

import Foundation

class QueueGate {
    private var group: DispatchGroup?
    private let queue: DispatchQueue
    
    init(queue: DispatchQueue) {
        self.queue = queue

    }
    
    public func pass() {
        group?.leave()
    }
    
    public func wait() {
        let waitGroup = DispatchGroup()
        waitGroup.enter()
        queue.async { waitGroup.leave() }
        waitGroup.wait()
    }
    
    public func passAndWait() {
        pass()
        wait()
    }
    
    public func schedule() {
        group = DispatchGroup()
        group!.enter()
        queue.async { self.group!.wait() }
    }
    
    static func scheduled(on queue: DispatchQueue) -> QueueGate {
        let gate = QueueGate(queue: queue)
        gate.schedule()
        return gate
    }
}
