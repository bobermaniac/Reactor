import Foundation

public class File: Disposable {
    public init(url: URL, mode: Mode = .read, queue: DispatchQueue = DispatchQueue.main) {
        _openFile = { return try mode.opener(url) }
        _queue = queue
    }
    
    public func dispose() {
    }
    
    public func read(options: ReadOperationOptions = .allContent) throws -> ReadOperation {
        let operation = try ReadOperation(with: _io(for: _openFile()), finalizer: _finalize(read:io:))
        operation.beginRead(with: options, on: _queue)
        return operation
    }
    
    private func _finalize(read operation: ReadOperation, io: DispatchIO) {
        io.close()
    }

    private func _io(for handle: FileHandle) -> DispatchIO {
        return DispatchIO(type: .random, fileDescriptor: handle.fileDescriptor, queue: _queue, cleanupHandler: { _ in handle.closeFile() })
    }
    
    private let _openFile: () throws -> FileHandle
    private let _queue: DispatchQueue
}

public extension File {
    public enum Chunk: Pulse {
        case data(DispatchData)
        case complete
        case failed(Error)
        
        public var obsolete: Bool {
            if case .data(_) = self { return false }
            return true
        }
    }
}

public extension File {
    public struct InvalidModeError: Error { }
    
    public struct Mode: OptionSet {
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public let rawValue: UInt
        
        public static let read = Mode(rawValue: 1 << 0)
        public static let write = Mode(rawValue: 1 << 1)
        
        var opener: (URL) throws -> FileHandle {
            if self.contains(.read) {
                if self.contains(.write) {
                    return FileHandle.init(forUpdating:)
                }
                return FileHandle.init(forReadingFrom:)
            }
            if self.contains(.write) {
                return FileHandle.init(forWritingTo:)
            }
            return { _ in throw InvalidModeError() }
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
