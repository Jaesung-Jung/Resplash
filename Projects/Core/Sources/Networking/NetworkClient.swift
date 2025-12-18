//
//  NetworkClient.swift
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

import Foundation
import Alamofire
import ResplashUtils
import ResplashLog

public struct NetworkClient: Sendable, ~Copyable {
  let baseURL: URL
  let session: Session

  public init(baseURL: URL) {
    self.baseURL = baseURL
    #if DEBUG
    self.session = Session(eventMonitors: [
      NetworkingEventMonitor(
        logger: Logger(label: "network-client")
      )
    ])
    #else
    self.session = Session()
    #endif
  }

  public func request(_ endpoint: Endpoint) async throws -> DataResponse {
    let url = baseURL.appending(path: endpoint.path)
    let request = session.request(url, method: endpoint.method, parameters: endpoint.parameters, encoding: URLEncoding.default)
    let data = try await request.validate().serializingData().value
    let decoder = JSONDecoder().then {
      $0.dateDecodingStrategy = .iso8601
    }
    return try decoder.decode(DataResponse.self, from: data)
  }
}

// MARK: - NetworkClient.DataResponse

extension NetworkClient {
  public struct DataResponse: Decodable {
    let decoder: Decoder

    public init(from decoder: Decoder) throws {
      self.decoder = decoder
    }

    public func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
      try T(from: decoder)
    }

    public func decode<T: Decodable>(_ type: T.Type = T.self, forKey key: String) throws -> T {
      let container = try decoder.container(keyedBy: StringCodingKey.self)
      let paths = key.split(separator: ".").compactMap { StringCodingKey($0) }
      guard let finalKey = paths.last else {
        fatalError("keyPath is empty.")
      }
      return try paths.dropLast(1)
        .reduce(container) { try $0.nestedContainer(keyedBy: StringCodingKey.self, forKey: $1) }
        .decode(type, forKey: finalKey)
    }
  }
}
