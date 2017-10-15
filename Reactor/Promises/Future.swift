import Foundation

public final class Future<T> {
    fileprivate let monitor: ContinuousSignal<Result<T>>
    
    init(on monitor: ContinuousSignal<Result<T>>) {
        self.monitor = monitor
    }
    
    public init(resolvedWith payload: T) {
        self.monitor = ContinuousSignal(initialValue: .payload(payload))
    }
    
    public init(rejectedWith error: Error) {
        self.monitor = ContinuousSignal(initialValue: .error(error))
    }
    
    public func resolved(_ handler: @escaping (T) -> Void) {
        monitor.observe { $0.unwrap(handler) }
    }
    
    public func rejected(_ handler: @escaping (Error) -> Void) {
        monitor.observe { $0.unwrap(handler) }
    }
    
    public func fulfilled(_ handler: @escaping () -> Void) {
        monitor.observe { $0.unwrap(handler) }
    }
}

@inline(__always)
func unwrap<T>(_ future: Future<T>) -> ContinuousSignal<Result<T>> {
    return future.monitor
}

@inline(__always)
func unwrap<T, U>(f: @escaping (T) -> Future<U>) -> (T) -> ContinuousSignal<Result<U>> {
    return { payload in unwrap(f(payload)) }
}

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
