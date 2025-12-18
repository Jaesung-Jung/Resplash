//
//  NetworkEventMonitor.swift
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

#if DEBUG

import Foundation
import Alamofire
import ResplashLog

struct NetworkingEventMonitor: EventMonitor {
  let logger: Logger

  func request(_ request: Request, didResumeTask task: URLSessionTask) {
    guard let description = requestDescription(for: request.request) else {
      return
    }
    logger.debug("🌐 \(description)")
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let httpResponse = dataTask.response as? HTTPURLResponse, let description = responseDescription(for: httpResponse) else {
      return
    }
    let validStatusCode = Set<Int>(200...299)
    if validStatusCode.contains(httpResponse.statusCode) {
      let message = ["💬 \(description)", dataDescription(for: data) ?? "⚠️ <NO RESPONSE DATA>"].joined(separator: "\n")
      logger.debug("\(message)")
    } else {
      let message = ["💬 \(description)", dataDescription(for: data)].compactMap { $0 }.joined(separator: "\n")
      logger.error("\(message)")
    }
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
    guard let description = requestDescription(for: task.originalRequest), let error else {
      return
    }
    let message = ["❌ \(description)", "\(error)"].joined(separator: "\n")
    logger.error("\(message)")
  }
}

// MARK: - NetworkingEventMonitor (Private)

extension NetworkingEventMonitor {
  private func requestDescription(for request: URLRequest?) -> String? {
    guard let method = request?.httpMethod, let url = request?.url else {
      return nil
    }
    return "[\(method)] \(url.absoluteString)"
  }

  private func responseDescription(for response: HTTPURLResponse?) -> String? {
    guard let response, let url = response.url else {
      return nil
    }
    return "\(url.absoluteString) (\(response.statusCode))"
  }

  private func dataDescription(for data: Data?) -> String? {
    return data
      .map {
        if let string = String(data: $0, encoding: .utf8) {
          return string
        }
        return "\($0.count.formatted(.byteCount(style: .memory, includesActualByteCount: true)))"
      }
  }

  private func headerDescription(for headers: HTTPHeaders?) -> String? {
    guard let headers, !headers.isEmpty else {
      return nil
    }
    return "\(headers.map { "\($0.name): \($0.value)" }.joined(separator: "\n"))"
  }
}

#endif
