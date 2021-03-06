import Foundation

extension ObservableValue where T == Bool {
    private static func _and(_ lhs: Bool, _ rhs: Bool) -> Bool { return lhs && rhs }
    private static func _or(_ lhs: Bool, _ rhs: Bool) -> Bool { return lhs || rhs }
    private static func _not(_ val: Bool) -> Bool { return !val }
    
    static func &&(_ lhs: ObservableValue<T>, _ rhs: ObservableValue<T>) -> ObservableValue<T> {
        return ObservableValue(on: tie(unwrap(lhs), unwrap(rhs), with: { tie($0, $1, _and) }))
    }
    
    static func ||(_ lhs: ObservableValue<T>, _ rhs: ObservableValue<T>) -> ObservableValue<T> {
        return ObservableValue(on: tie(unwrap(lhs), unwrap(rhs), with: { tie($0, $1, _or) }))
    }
    
    static prefix func !(_ observable: ObservableValue<T>) -> ObservableValue<T> {
        return ObservableValue(on: unwrap(observable).fmap { $0.fmap(_not) })
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
