import Foundation

private func _checked<Result: Pulse>(input: [ Pulse ], result: Result) -> Result {
    guard input.all({ $0.obsolete }) => result.obsolete else { fatalError() }
    return result
}

func tie<Left, Right, Result>(_ lhs: ContinuousSignal<Left>, _ rhs: ContinuousSignal<Right>, with transform: @escaping (Left, Right) -> Result) -> ContinuousSignal<Result> {
    let (transport, monitor) = ContinuousSignalFactory(initialValue: transform(lhs.value, rhs.value)).createBound()
    
    func _sendTransformedChecked(_ lhs: Left, _ rhs: Right) {
        transport.receive(_checked(input: [ lhs, rhs ], result: transform(lhs, rhs)))
    }
    
    lhs.observe { payload in _sendTransformedChecked(payload, rhs.value) }
    rhs.observe { payload in _sendTransformedChecked(lhs.value, payload) }
    
    return monitor
}

func tie<T, Result>(_ input: [ ContinuousSignal<T> ], with transform: @escaping ([ T ]) -> Result) -> ContinuousSignal<Result> {
    let (transport, monitor) = ContinuousSignalFactory(initialValue: transform(input.map { $0.value })).createBound()
    
    func _sendTransformedChecked(_ values: [ T ]) {
        transport.receive(_checked(input: values, result: transform(values)))
    }
    
    input.forEach { $0.observe { payload in _sendTransformedChecked(input.map { $0.value }) } }
    
    return monitor
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
