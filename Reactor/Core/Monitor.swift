import Foundation

public class Monitor<T: Pulse> {
    init(kind: SignalKind<T>) {
        state = State.initial(kind: Kind.from(signalKind: kind))
    }
    
    init(kind: Kind) {
        state = State.initial(kind: kind)
    }
    
    public func attached(to transport: Transport<T>) -> Monitor<T> {
        transport.collector = self.process
        return self
    }
    
    @discardableResult
    public func subscribe(_ handler: @escaping (T) -> Void) -> Observer {
        let observer = Observer(notify: handler, cancel: self.remove)
        state = state.add(observer: observer)
        state.signal(to: observer)
        return observer
    }
    
    public func remove(subscription observer: Observer) {
        state = state.remove(observer: observer)
    }
    
    public class Observer {
        let notify: (T) -> Void
        let cancel: (Observer) -> Void
        
        public func stop() {
            cancel(self)
        }
        
        init(notify: @escaping (T) -> Void, cancel: @escaping (Observer) -> Void) {
            self.notify = notify
            self.cancel = cancel
        }
    }

    private func process(_ event: T) {
        let (newState, invocation) = state.handle(event: event)
        state = newState
        invocation()
    }
    
    private var state: State
    
    public var kind: Kind {
        return state.kind
    }
    
    public enum Kind {
        case instant
        case continuous(T)
        
        static func from(signalKind: SignalKind<T>) -> Kind {
            switch signalKind {
            case .intermittent:
                return .instant
            case .continuous(initial: let payload):
                return .continuous(payload)
            }
        }
        
        func process(_ handler: (T) -> Void) {
            guard case .continuous(let payload) = self else { return }
            handler(payload)
        }
        
        func update(payload: T) -> Kind {
            guard case .continuous(_) = self else { return self }
            return .continuous(payload)
        }
    }
    
    indirect private enum State {
        case active(Kind, [ Observer ])
        case terminated(T)
        
        static func initial(kind: Kind) -> State {
            return .active(kind, [])
        }
        
        func add(observer: Observer) -> State {
            guard case .active(let signal, let observers) = self else { return self }
            return .active(signal, observers + [ observer ])
        }
        
        func signal(to observer: Observer) {
            switch self {
            case .active(let signal, _):
                signal.process(observer.notify)
            case .terminated(let payload):
                observer.notify(payload)
            }
        }
        
        func remove(observer: Observer) -> State {
            guard case .active(let signal, var observers) = self else { return self }
            guard let index = observers.index(where: { $0 === observer }) else { return self }
            observers.remove(at: index)
            return .active(signal, observers)
        }
        
        func handle(event: T) -> (State, invocation: () -> Void) {
            guard case .active(let signal, let observers) = self else { return (self, {}) }
            let invocation = { observers.forEach { $0.notify(event) } }
            if event.terminal {
                return (.terminated(event), invocation)
            } else {
                return (.active(signal.update(payload: event), observers), invocation)
            }
        }
        
        var kind: Kind {
            switch self {
            case .active(let kind, _):
                return kind
            case .terminated(let payload):
                return .continuous(payload)
            }
        }
    }
}
