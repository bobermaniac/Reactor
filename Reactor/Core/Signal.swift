import Foundation

protocol Subscription {
    func cancel()
}

protocol Signal {
    associatedtype PayloadType: Pulse
    
    @discardableResult
    func observe(with handler: @escaping (PayloadType) -> Void) -> Subscription
}
