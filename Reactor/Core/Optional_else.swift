import Foundation

extension Optional {
    func otherwise(value: Wrapped) -> Optional {
        switch self {
        case .none:
            return .some(value)
        case .some(_):
            return self
        }
    }
}
