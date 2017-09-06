import Foundation

class SignalCore<Payload: Pulse> {
    class Subscriber : Subscription {
        public let notify: (Payload) -> Void
        
        public func cancel() {
            canceler(self)
        }
        
        init(notify: @escaping (Payload) -> Void, canceler: @escaping (Subscriber) -> Void) {
            self.notify = notify
            self.canceler = canceler
        }
        
        let canceler: (Subscriber) -> Void
    }
    
    private var state: State = State.initial()
    
    private func apply(update: State.Update) {
        self.state = update.state
        update.invocation?()
    }
    
    func consume(_ payload: Payload) {
        apply(update: state.updated(with: payload))
    }
    
    func add(observer: @escaping (Payload) -> Void) -> Subscription {
        let subscriber = Subscriber(notify: observer, canceler: self.remove)
        apply(update: state.added(subscriber: subscriber))
        return subscriber
    }
    
    private func remove(subscriber: Subscriber) {
        apply(update: state.removed(subscriber: subscriber))
    }
    
    indirect enum State {
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
