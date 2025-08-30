//
//  Logger.swift
//
//  Copyright © 2025 Jaesung Jung. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import OSLog

struct Logger: Sendable {
  @inlinable func log(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    printLog(file: file, function: function, line: line) {
      let log = "\(message())"
      $0.log("\(log)")
    }
  }

  @inlinable func debug(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    printLog(file: file, function: function, line: line) {
      let log = "\(message())"
      $0.debug("\(log)")
    }
  }

  @inlinable func info(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    printLog(file: file, function: function, line: line) {
      let log = "\(message())"
      $0.info("\(log)")
    }
  }

  @inlinable func fault(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    printLog(file: file, function: function, line: line) {
      let log = "\(message())"
      $0.fault("\(log)")
    }
  }

  @inlinable func error(_ message: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    printLog(file: file, function: function, line: line) {
      let log = "\(message())"
      $0.error("\(log)")
    }
  }

  private func printLog(file: String, function: String, line: Int, message: (borrowing os.Logger) -> Void) {
    #if DEBUG
    let logger = os.Logger(subsystem: className(file: file), category: "\(function):\(line)")
    message(logger)
    #endif
  }

  private func className(file: String) -> String {
    guard let endIndex = file.reversed().firstIndex(of: ".")?.base else {
      return file
    }
    let startIndex = file.reversed().firstIndex(of: "/")?.base ?? file.startIndex
    return String(file[startIndex..<file.index(before: endIndex)])
  }
}
