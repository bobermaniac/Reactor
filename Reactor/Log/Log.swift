import Foundation

public enum LogLevel {
    case error
    case warning
    case info
    case verbose
    case debug
}

public protocol Logger {
    func print(_ string: String)
    
    func shouldLog(group: String) -> Bool
    func shouldLog(level: LogLevel) -> Bool
}

public struct Logging {
    public class Default: Logger {
        public func print(_ string: String) {
            print(string)
        }
        
        public func shouldLog(group: String) -> Bool {
            return true
        }
        
        public func shouldLog(level: LogLevel) -> Bool {
            return true
        }
    }
    
    private init() { }
    private static var _loggers: [ Logger ] = []
    
    public static func register(logger: Logger) {
        _loggers.append(logger)
    }
    
    public static func enumerate(loggers block: (Logger) -> Void) {
        _loggers.forEach(block)
    }
}

public let DefaultLogGroup = "default"

public func log(_ string: @autoclosure () -> String) {
    log(string, group: DefaultLogGroup, level: .debug)
}

public func log(_ string: @autoclosure () -> String, group: String) {
    log(string, group: group, level: .debug)
}

public func log(_ string: @autoclosure () -> String, level: LogLevel) {
    log(string, group: DefaultLogGroup, level: level)
}

public func log(_ string: @autoclosure () -> String, group: String, level: LogLevel) {
    Logging.enumerate(loggers: { logger in
        if logger.shouldLog(group: group) && logger.shouldLog(level: level) {
            logger.print(string())
        }
    })
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
