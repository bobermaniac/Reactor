import Foundation

public class Source<T: Pulse> {
    public let emit: (T) -> Void
    public let monitor: Monitor<T>
    
    init(kind: SignalKind<T>) {
        let transport = Transport<T>()
        (emit, monitor) = (transport.emit, Monitor<T>(kind: kind).attached(to: transport))
    }
}
