import Foundation

protocol Observation {
    func cancel()
}

protocol Monitor {
    associatedtype PayloadType: Pulse
    
    @discardableResult
    func observe(with handler: @escaping (PayloadType) -> Void) -> Observation
}
