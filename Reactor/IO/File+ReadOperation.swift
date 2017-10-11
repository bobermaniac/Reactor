import Foundation

public struct ReadOperationOptions {
    public let offset: off_t
    public let size: size_t
    
    public static let allContent = ReadOperationOptions(offset: 0, size: .max)
}

public struct ReadOperationError: Error {
    public let code: Int32
}

public struct ReadOperationDisposed: Error { }

public extension File {
    public class ReadOperation : Disposable, SignalProviding {
        public typealias Finalizer = (ReadOperation, DispatchIO) -> Void
        
        private enum _State {
            case finalized
            case pending(Finalizer)
            
            mutating func perform(dispose operation: ReadOperation, io: DispatchIO) {
                switch self {
                case .pending(let finalizer):
                    finalizer(operation, io)
                    self = .finalized
                default:
                    break
                }
            }
            
            var pending: Bool {
                if case .pending(_) = self { return true }
                return false
            }
        }
        
        init(with io: DispatchIO, finalizer: @escaping Finalizer) {
            _io = io
            _emitter = Emitter(factory: DiscreteSignalFactory<Chunk>())
            _state = .pending(finalizer)
        }
        
        public func dispose() {
            _emitter.emit(.failed(ReadOperationDisposed()))
            _state.perform(dispose: self, io: _io)
        }
        
        public typealias SignalType = DiscreteSignal<Chunk>
        
        public var signal: SignalType {
            return _emitter.monitor
        }
        
        func beginRead(with options: ReadOperationOptions, on queue: DispatchQueue) {
            func handler(complete: Bool, data: DispatchData?, error: Int32) {
                if _state.pending {
                    if complete {
                        if error != 0 {
                            _emitter.emit(.failed(ReadOperationError(code: error)))
                        } else {
                            _emitter.emit(.complete)
                        }
                    }
                    _emitter.emit(.data(data!))
                }
            }
            
            _io.read(offset: options.offset, length: options.size, queue: queue, ioHandler: handler)
        }
        
        private let _emitter: Emitter<DiscreteSignal<Chunk>>
        private let _io: DispatchIO
        private var _state: _State
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
