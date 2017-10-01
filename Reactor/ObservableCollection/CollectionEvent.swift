import Foundation

public struct CollectionEvent<T>: CustomDebugStringConvertible {
    public typealias IndexType = Int
    
    public let index: IndexType
    public let payload: T
    public let kind: Kind
    
    public indirect enum Kind {
        case added
        case removed
        case updated(T)
    }
    
    init(_ kind: Kind, payload: T, index: IndexType) {
        self.kind = kind
        self.payload = payload
        self.index = index
    }
    
    static func added(_ payload: T, index: IndexType) -> CollectionEvent<T> {
        return CollectionEvent<T>(.added, payload: payload, index: index)
    }
    
    static func removed(_ payload: T, index: IndexType) -> CollectionEvent<T> {
        return CollectionEvent<T>(.removed, payload: payload, index: index)
    }
    
    static func updated(_ previous: T, with payload: T, index: IndexType) -> CollectionEvent<T> {
        return CollectionEvent<T>(.updated(previous), payload: payload, index: index)
    }
    
    public var debugDescription: String {
        switch kind {
        case .updated(let old):
            return "updated from \(old) to \(payload) at \(index)"
        default:
            return "\(kind) \(payload) at \(index)"
        }

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
