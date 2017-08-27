import Foundation

extension Sequence {
    func all(_ satisfying: (Element) -> Bool) -> Bool {
        return self.first(where: { !satisfying($0) }) == nil
    }
    
    func any(_ satisfying: (Element) -> Bool) -> Bool {
        return self.first(where: satisfying) != nil
    }
}
