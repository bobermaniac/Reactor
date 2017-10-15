import Foundation

public enum Result<T> : Pulse {
    case nothing
    case payload(T)
    case error(Error)
    
    public var obsolete: Bool {
        if case .nothing = self { return false }
        return true
    }
    
    func unwrap(_ receiver: () -> Void) {
        switch self {
        case .nothing:
            return
        default:
            receiver()
        }
    }
    
    func unwrap(_ receiver: (T) -> Void) {
        guard case let .payload(object) = self else { return }
        receiver(object)
    }
    
    func unwrap(_ receiver: (Error) -> Void) {
        guard case let .error(error) = self else { return }
        receiver(error)
    }
    
    func fmap<U>(_ transform: (T) throws -> U) -> Result<U> {
        guard case let .payload(object) = self else { return cast() }
        do { return .payload(try transform(object)) }
        catch (let error) { return .error(error) }
    }
    
    func fmap<U>(payload pt: (T) -> U, error et: (Error) -> U) -> U {
        switch self {
        case .nothing:
            fatalError("Nothing can't be transformed")
        case .payload(let payload):
            return pt(payload)
        case .error(let error):
            return et(error)
        }
    }
    
    func cast<U>() -> Result<U> {
        switch self {
        case .nothing:
            return .nothing
        case let .error(error):
            return .error(error)
        case let .payload(payload):
            return .payload(payload as! U)
        }
    }
    
    func fail(transform: (Error) throws -> T) -> Result<T> {
        guard case let .error(error) = self else { return self }
        do { return .payload(try transform(error)) }
        catch (let error) { return .error(error) }
    }
    
    static func concat<T>(_ lhs: Result<[ T ]>, _ rhs: Result<T>) -> Result<[ T ]> {
        guard case let .payload(payloads) = lhs else { return lhs }
        guard case let .payload(payload) = rhs else { return rhs.cast() }
        return .payload(payloads + [ payload ])
    }
    
    static func select<T>(_ lhs: Result<T>, _ rhs: Result<T>) -> Result<T> {
        if case .payload(_) = lhs { return lhs }
        if case .error(_) = rhs { return lhs }
        return rhs
    }
}

func all<T>(_ results: [ Result<T> ]) -> Result<[ T ]> {
    return results.reduce(Result<[ T ]>.payload([]), Result<T>.concat)
}

struct AllRejected: Error { }

func any<T>(_ results: [ Result<T> ]) -> Result<T> {
    return results.reduce(.error(AllRejected()), Result<T>.select)
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
