import Foundation

private var logGroup = "Reactor::Bubbling"

private func _log(_ string: @autoclosure () -> String) {
    log(string, group: logGroup, level: .debug)
}

extension CollectionEvent {
    func update(index update: (IndexType) -> IndexType) -> CollectionEvent<T> {
        return CollectionEvent(kind, payload: payload, index: update(index))
    }
    
    func update(payload: T) -> CollectionEvent<T> {
        return CollectionEvent(kind, payload: payload, index: index)
    }
    
    func bubble(through events: [ CollectionEvent<T> ]) -> [ CollectionEvent<T> ] {
        func _debugPrint(events: [ CollectionEvent<T> ]) -> String {
            return events.reduce("", { "\($0) [\($1.debugDescription)]" })
        }
        _log("Bubbling [\(self)] through \(_debugPrint(events: events))")
        var result: [ CollectionEvent<T> ] = []
        var bubble = self as CollectionEvent<T>?
        
        events.reversed().forEach { item in
            _log("Bubbling [\(bubble.map { $0.debugDescription } ?? "empty")] through [\(item)]")
            switch _bubble(event: bubble, through: item) {
            case let .update(append: replacement, bubble: next):
                replacement.map {
                    _log("Appending [\($0)]")
                    result.append($0)
                }
                bubble = next
                bubble.map { print("[\($0)] bubbles") }
            case .insert:
                _log("[\(bubble!)] founds its place before [\(item)]")
                result += [ bubble!, item ]
                bubble = nil
            }
        }
        
        bubble.map {
            _log("[\($0)] goes to the end")
            result.append($0)
        }
        
        let returnValue = result.reversed() as [ CollectionEvent<T> ]
        _log("Result is \(_debugPrint(events: returnValue))")
        return returnValue
    }
}

private enum _BubbleResult<T> {
    case update(append: CollectionEvent<T>?, bubble: CollectionEvent<T>?)
    case insert
}

private func _bubble<T>(event: CollectionEvent<T>?, through prev: CollectionEvent<T>) -> _BubbleResult<T> {
    guard let candidate = event else { return .update(append: prev, bubble: nil) }
    switch candidate.kind {
    case .added:
        switch prev.kind {
        case .added where prev.index >= candidate.index:
            return .update(append: prev.update(index: { $0 + 1 }), bubble: candidate)
        default:
            break
        }
    case .updated(_):
        switch prev.kind {
        case .added where prev.index < candidate.index:
            return .update(append: prev, bubble: candidate.update(index: { $0 - 1 }))
        case .added where prev.index == candidate.index:
            return .update(append: prev.update(payload: candidate.payload), bubble: nil)
        case .added:
            return .update(append: prev, bubble: candidate)
        case .updated(_) where prev.index > candidate.index:
            return .update(append: prev, bubble: candidate)
        case .updated(_) where prev.index == candidate.index:
            return .update(append: prev.update(payload: candidate.payload), bubble: nil)
        default:
            break
        }
    case .removed:
        switch prev.kind {
        case .added where prev.index < candidate.index:
            return .update(append: prev, bubble: candidate.update(index: { $0 - 1 }))
        case .added where prev.index == candidate.index:
            return .update(append: nil, bubble: nil)
        case .added:
            return .update(append: prev.update(index: { $0 - 1 }), bubble: candidate)
        case .updated(_) where prev.index == candidate.index:
            return .update(append: nil, bubble: candidate)
        case .updated(_):
            return .update(append: prev.update(index: { $0 - 1}), bubble: candidate)
        case .removed where prev.index <= candidate.index:
            return .update(append: prev, bubble: candidate.update(index: { $0 + 1 }))
        case .removed:
            break
        }
    }
    return .insert
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
