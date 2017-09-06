import Foundation

public class Pipeline<Payload> {
    func send(_ payload: Payload) {
        receiver?(payload)
    }
    
    var receiver: ((Payload) -> Void)?
}
