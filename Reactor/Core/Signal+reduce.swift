import Foundation

extension Signal {
    func reduce<Accumulator>(initial: Accumulator, _ aggregate: @escaping (PayloadType, Accumulator) -> Accumulator) -> ContinuousSignal<Accumulator> {
        func _checked(input: Pulse, output: Accumulator) -> Accumulator {
            guard input.obsolete => output.obsolete else { fatalError() }
            return output
        }
        let (transport, signal) = ContinuousSignalFactory(initialValue: initial).createBound()
        
        var accumulator = initial
        self.observe { payload in
            accumulator = _checked(input: payload, output: aggregate(payload, accumulator))
            transport.receive(accumulator)
        }
        
        return signal
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
