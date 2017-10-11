import Foundation

class Promise<T> {
    private let emitter: Emitter<ContinuousSignal<Result<T>>>
    public let future: Future<T>
    
    init() {
        emitter = Emitter(factory: ContinuousSignalFactory(initialValue: Result<T>.nothing))
        future = Future(on: emitter.monitor)
    }
    
    func resolve(_ payload: T) {
        emitter.emit(.payload(payload))
    }
    
    func reject(_ error: Error) {
        emitter.emit(.error(error))
    }
}

class Future<T> {
    fileprivate let monitor: ContinuousSignal<Result<T>>
    
    init(on monitor: ContinuousSignal<Result<T>>) {
        self.monitor = monitor
    }
    
    init(resolvedWith payload: T) {
        self.monitor = ContinuousSignal(initialValue: .payload(payload))
    }
    
    init(rejectedWith error: Error) {
        self.monitor = ContinuousSignal(initialValue: .error(error))
    }
    
    func resolved(_ handler: @escaping (T) -> Void) {
        monitor.observe { $0.unwrap(handler) }
    }
    
    func rejected(_ handler: @escaping (Error) -> Void) {
        monitor.observe { $0.unwrap(handler) }
    }
    
    func then<U>(_ transform: @escaping (T) throws -> U) -> Future<U> {
        return Future<U>(on: monitor.fmap { $0.fmap(transform) })
    }
    
    func then<U>(_ transform: @escaping (T) -> Future<U>) -> Future<U> {
        func lift(_ val: Result<T>) -> ContinuousSignal<Result<U>> {
            return val.extend(unwrap(f: transform))
        }
        return Future<U>(on: monitor.extend(intermediateTransform: { _ in .nothing }, finalTransform: lift))
    }
    
    func handle(_ transform: @escaping (Error) throws -> T) -> Future<T> {
        return Future(on: monitor.fmap { $0.fail(transform: transform) })
    }
    
    func transfer(to queue: DispatchQueue) -> Future<T> {
        return Future(on: monitor.transfer(to: queue))
    }
}

func all<T>(_ futures: [ Future<T> ]) -> Future<[ T ]> {
    return Future(on: tie(futures.map { $0.monitor }, with: all))
}

func any<T>(_ futures: [ Future<T> ]) -> Future<T> {
    return Future(on: tie(futures.map { $0.monitor }, with: any))
}

func unwrap<T>(_ future: Future<T>) -> ContinuousSignal<Result<T>> {
    return future.monitor
}

func unwrap<T, U>(f: @escaping (T) -> Future<U>) -> (T) -> ContinuousSignal<Result<U>> {
    func unwrapper(_ payload: T) -> ContinuousSignal<Result<U>> {
        return unwrap(f(payload))
    }
    return unwrapper
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
