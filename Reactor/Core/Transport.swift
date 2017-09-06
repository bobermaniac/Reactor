import Foundation

public class Transport<Payload> {
    func send(_ payload: Payload) {
        receiver?(payload)
    }
    
    var receiver: ((Payload) -> Void)?
}
