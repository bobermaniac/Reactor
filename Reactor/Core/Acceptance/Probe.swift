import Foundation

struct Probe: Pulse, Equatable, Hashable {
    var hashValue: Int {
        return value
    }
    
    static func ==(lhs: Probe, rhs: Probe) -> Bool {
        return lhs.value == rhs.value
    }
    
    private let value: Int
    
    private init(_ value: Int) {
        self.value = value
    }
    
    static var obsolete: Probe {
        return Probe(0)
    }
    
    static func signal() -> Probe {
        return Probe(Int(arc4random()))
    }
    
    static func signals(count: Int) -> [ Probe ] {
        return (0..<count).map { _ in signal() }
    }
    
    var obsolete: Bool {
        return value == 0
    }
}

typealias Probes = [ Probe ]

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
