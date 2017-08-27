import Foundation

public class Transport<T> {
    public var collector: ((T) -> Void)?
    public func emit(_ value: T) { collector?(value) }
}
