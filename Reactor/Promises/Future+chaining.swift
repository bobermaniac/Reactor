import Foundation

extension Future {
    public func then<U>(_ transform: @escaping (T) throws -> U) -> Future<U> {
        return Future<U>(on: unwrap(self).fmap { $0.fmap(transform) })
    }
    
    public func then<U>(_ transform: @escaping (T) -> Future<U>) -> Future<U> {
        func createSignal(from result: Result<T>) -> ContinuousSignal<Result<U>> {
            return result.fmap(payload: unwrap(f: transform),
                               error: { ContinuousSignal(initialValue: .error($0)) })
        }
        return Future<U>(on: unwrap(self).extend(intermediate: .nothing, finalTransform: createSignal))
    }
    
    public func then<U>(_ transform: @escaping (T) -> ObservableValue<U>, initial: U) -> ObservableValue<U> {
        func createSignal(from result: Result<T>) -> ContinuousSignal<Event<U>> {
            return result.fmap(payload: unwrap(f: transform),
                               error: { ContinuousSignal(initialValue: .faulted($0)) })
        }
        return ObservableValue(on: unwrap(self).extend(intermediate: .changed(initial), finalTransform: createSignal))
    }
    
    public func handle(_ transform: @escaping (Error) throws -> T) -> Future<T> {
        return Future(on: unwrap(self).fmap { $0.fail(transform: transform) })
    }
    
    public func handle(_ transform: @escaping (Error) -> Future<T>) -> Future<T> {
        func createSignal(from result: Result<T>) -> ContinuousSignal<Result<T>> {
            return result.fmap(payload: { ContinuousSignal(initialValue: .payload($0)) },
                               error: unwrap(f: transform) )
        }
        return Future<T>(on: unwrap(self).extend(with: createSignal))
    }
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
