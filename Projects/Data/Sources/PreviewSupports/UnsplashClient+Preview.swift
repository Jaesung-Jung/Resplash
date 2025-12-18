//
//  UnsplashClient+Preview.swift
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
import ResplashClients
internal import ResplashClientFactory
internal import ResplashNetworking

extension UnsplashClient {
  public static func preview() -> UnsplashClient {
    let bundle = Bundle(for: BundleFinder.self)
    return makeClient { endpoint in
      let data = try bundle
        .url(forResource: endpoint.resourceId, withExtension: "json")
        .map { try Data(contentsOf: $0) }
      let decoder = JSONDecoder().then {
        $0.dateDecodingStrategy = .iso8601
      }
      return try decoder.decode(NetworkClient.DataResponse.self, from: data ?? Data())
    }
  }
}

private class BundleFinder {
}

#endif
