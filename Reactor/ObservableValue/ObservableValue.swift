import Foundation

public final class ObservableValue<T> {
    fileprivate let monitor: ContinuousSignal<Event<T>>
    
    public init(on monitor: ContinuousSignal<Event<T>>) {
        self.monitor = monitor
    }
    
    public func subscribe(onChange handler: @escaping (Event<T>) -> Void) -> Subscription {
        return monitor.observe(with: handler)
    }
    
    public func fmap<U>(_ transform: @escaping (T) throws -> U) -> ObservableValue<U> {
        return ObservableValue<U>(on: monitor.fmap { $0.fmap(transform) })
    }
    
    public func filter(initial: T, _ predicate: @escaping (T) -> Bool) -> ObservableValue<T> {
        return ObservableValue(on: monitor.filter(initial: .changed(initial), { $0.satisfies(predicate) }))
    }
    
    public func reduce<A>(initial accumulator: A, _ reducer: @escaping (A, T) -> A) -> ObservableValue<A> {
        func collect(next event: Event<T>, to accumulator: Event<A>) -> Event<A> {
            return accumulator.apply(to: event, reducer)
        }
        
        return ObservableValue<A>(on: monitor.reduce(initial: .changed(accumulator), collect))
    }
    
    public func zip<U, R>(with: ObservableValue<U>, _ zipper: @escaping (T, U) -> R) -> ObservableValue<R> {
        func zip(_ lhs: Event<T>, rhs: Event<U>) -> Event<R> {
            return lhs.apply(to: rhs, zipper)
        }
        return ObservableValue<R>(on: tie(monitor, with.monitor, with: zip))
    }
    
    public func follow(with factory: @escaping () -> ObservableValue<T>) -> ObservableValue<T> {
        func follower(_ event: Event<T>) -> ContinuousSignal<Event<T>> {
            return unwrap(factory())
        }
        return ObservableValue<T>(on: monitor.extend(with: follower))
    }
    
    public func transfer(to queue: DispatchQueue) -> ObservableValue<T> {
        return ObservableValue<T>(on: monitor.transfer(to: queue))
    }
}

@inline(__always)
func unwrap<T>(_ value: ObservableValue<T>) -> ContinuousSignal<Event<T>> {
    return value.monitor
}

@inline(__always)
func unwrap<T, U>(f: @escaping (T) -> ObservableValue<U>) -> (T) -> ContinuousSignal<Event<U>> {
    return { unwrap(f($0)) }
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
