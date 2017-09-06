import Foundation

class MutableValue<T> {
    private let emitter: Emitter<ContinuousMonitor<Event<T>>>
    public let observable: ObservableValue<T>
    
    init(initial value: T) {
        emitter = Emitter(monitorFactory: { ContinuousMonitor.create(attachedTo: $0, initialValue: .changed(value)) })
        observable = ObservableValue(on: emitter.monitor)
        self.value = value
    }
    
    public var value: T {
        didSet {
            emitter.emit(.changed(value))
        }
    }
    
    deinit {
        emitter.emit(.depleted)
    }
}
