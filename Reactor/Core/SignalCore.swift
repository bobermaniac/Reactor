import Foundation

final class SignalCore<Payload: Pulse> {
    private var state: State
    
    init(payload: Payload) {
        guard payload.obsolete else { fatalError() }
        state = .terminated(payload)
    }
    
    init() {
        state = .initial()
    }
    
    func consume(_ payload: Payload) {
        apply(update: state.updated(with: payload))
    }
    
    func add(observer: @escaping (Payload) -> Void) -> Subscription {
        let subscriber = Subscriber(notify: { (p, s) in observer(p) }, canceler: self.remove)
        apply(update: state.added(subscriber: subscriber))
        return subscriber
    }
    
    func add(observer: @escaping (Payload, Subscription) -> Void) -> Subscription {
        let subscriber = Subscriber(notify: observer, canceler: self.remove)
        apply(update: state.added(subscriber: subscriber))
        return subscriber
    }
    
    private func apply(update: State.Update) {
        self.state = update.state
        update.invocation?()
    }
    
    private func remove(subscriber: Subscriber) {
        apply(update: state.removed(subscriber: subscriber))
    }
    
    private class Subscriber : Subscription {
        public func notify(_ payload: Payload) {
            notifyInternal(payload, self)
        }
        
        private let notifyInternal: (Payload, Subscriber) -> Void
        
        public func cancel() {
            canceler(self)
        }
        
        init(notify: @escaping (Payload, Subscription) -> Void, canceler: @escaping (Subscriber) -> Void) {
            notifyInternal = notify
            self.canceler = canceler
        }
        
        let canceler: (Subscriber) -> Void
    }
    
    private indirect enum State {
        case active([ Subscriber ])
        case terminated(Payload)
        
        typealias Invocation = () -> Void
        typealias Update = (state: State, invocation: Invocation?)
        
        func added(subscriber: Subscriber) -> Update {
            switch self {
            case let .active(subscribers):
                return update(.active(subscribers + [ subscriber ]))
            case let .terminated(payload):
                return invoke(subscriber, with: payload)
            }
        }
        
        func removed(subscriber: Subscriber) -> Update {
            guard case .active(let subscribers) = self else { return unchanged() }
            return update(.active(subscribers.filter { $0 !== subscriber }))
        }
        
        func updated(with payload: Payload) -> Update {
            guard case .active(let subscribers) = self else { return unchanged() }
            if payload.obsolete { return update(.terminated(payload), andInvoke: subscribers, with: payload) }
            return invoke(subscribers, with: payload)
        }
        
        static func initial() -> State {
            return .active([])
        }
        
        private func update(_ state: State, andInvoke subscribers: [ Subscriber ], with payload: Payload) -> Update {
            return (state, { subscribers.forEach { s in s.notify(payload) } })
        }
        
        private func invoke(_ subscribers: [ Subscriber ], with payload: Payload) -> Update {
            return update(self, andInvoke: subscribers, with: payload)
        }
        
        private func invoke(_ subscriber: Subscriber, with payload: Payload) -> Update {
            return (self, { subscriber.notify(payload) })
        }
        
        private func update(_ state: State) -> Update {
            return (state, nil)
        }
        
        private func unchanged() -> Update {
            return (self, nil)
        }
    }
}

// Copyright (c) 2017 Victor Bryksin <vbryksin@virtualmind.ru>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
