import Foundation

public extension Monitor {
    func transfer(on queue: DispatchQueue) -> Monitor<T> {
        let transport = Transport<T>()
        let monitor = Monitor<T>(kind: self.kind).attached(to: transport)
        self.subscribe { event in
            queue.async { transport.emit(event) }
        }
        return monitor
    }
}
