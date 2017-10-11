import Foundation

enum Event<T>: Pulse {
    case changed(T)
    case depleted
    case faulted(Error)
    
    var obsolete: Bool {
        if case .changed(_) = self { return false }
        return true
    }
    
    func fmap<U>(_ transform: (T) throws -> U) -> Event<U> {
        guard case let .changed(payload) = self else { return cast() }
        do {
            return .changed(try transform(payload))
        } catch(let error) {
            return .faulted(error)
        }
    }
    
    func cast<U>() -> Event<U> {
        switch self {
        case let .changed(payload):
            return .changed(payload as! U)
        case .depleted:
            return .depleted
        case let .faulted(error):
            return .faulted(error)
        }
    }
}
func terminal<T1, T2, TResult>(_ left: Event<T1>, _ right: Event<T2>) -> Event<TResult> {
    if left.obsolete { return left.cast() }
    if right.obsolete { return right.cast() }
    fatalError("None is terminal")
}

func tie<T1, T2, TResult>(_ left: Event<T1>, _ right: Event<T2>, _ transform: (T1, T2) -> TResult) -> Event<TResult> {
    guard case let .changed(leftPayload) = left else { return terminal(left, right) }
    guard case let .changed(rightPayload) = right else { return terminal(left, right) }
    return .changed(transform(leftPayload, rightPayload))
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
