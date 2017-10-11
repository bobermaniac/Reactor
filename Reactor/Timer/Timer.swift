import Foundation

/*public class Timer : Disposable {
    public enum Event {
        case tick
        case disposed
    }
    
    public class TimerEvents : Disposable, SignalProviding {
        public func dispose() {
            
        }
        
        public typealias SignalType = Timer.Event
        
        public let signal: Timer.Event
    }
    
    public init(interval: TimeInterval, on queue: DispatchQueue = .main) {
        _timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        _interval = interval
        _disposed = false
    }
    
    deinit {
        dispose()
    }
    
    public func dispose() {
        guard !_disposed else { return }
        _timer.cancel()
        _disposed = true
    }
    
    public func start() -> TimerEvents {
        _timer.schedule(deadline: .seconds(_interval), repeating: .seconds(_interval))
    }
    
    private func _stop(events: TimerEvents) {
        
    }
    
    private let _timer: DispatchSourceTimer
    private let _interval: TimeInterval
    private var _disposed: Bool
}*/

// Copyright (c) 2017 Victor Bryksin <vbryksin@virtualmind.ru>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
