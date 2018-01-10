import Foundation

struct AcceptranceAssertion<T>: CustomStringConvertible  {
    let expected: T
    let actual: T
    var description: String
}

typealias AcceptanceBoolAssertion = AcceptranceAssertion<Bool>

func specify<T>(_ value: T) -> SpecifiedValue<T> {
    return SpecifiedValue(actual: value)
}

struct SpecifiedValue<T> {
    let actual: T
    
    func equals(to other: T) -> SpecifiedPair<T> {
        return SpecifiedPair(actual: actual, expected: other)
    }
}

extension SpecifiedValue where T == Bool {
    func isTrue() -> SpecifiedPair<T> {
        return SpecifiedPair(actual: actual, expected: true)
    }
}

struct SpecifiedPair<T> {
    let actual: T
    let expected: T
    
    func because(_ string: String) -> AcceptranceAssertion<T> {
        return AcceptranceAssertion(expected: expected, actual: actual, description: string)
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
