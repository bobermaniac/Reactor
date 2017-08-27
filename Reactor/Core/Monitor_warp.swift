import Foundation

public extension Monitor {
    func warp(to kind: SignalKind<T>) -> Monitor<T> {
        let transport = Transport<T>()
        let monitor = Monitor<T>(kind: kind).attached(to: transport)
        self.subscribe { transport.emit($0) }
        return monitor
    }
}
