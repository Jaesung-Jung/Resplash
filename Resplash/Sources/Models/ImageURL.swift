//
//  ImageURL.swift
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

struct ImageURL {
  let raw: URL
  let full: URL
  let s3: URL

  @inlinable var fhd: URL? { url(.fhd) }
  @inlinable var hd: URL? { url(.hd) }
  @inlinable var sd: URL? { url(.sd) }
  @inlinable var low: URL? { url(.low) }

  @inlinable func url(_ size: Size) -> URL? {
    url(size.rawValue, quality: size.quality)
  }

  @inlinable func url(size: CGFloat, quality: Int = 80) -> URL? {
    url(Int(size))
  }

  func url(_ size: Int, quality: Int = 80) -> URL? {
    guard var component = URLComponents(string: raw.absoluteString) else {
      return nil
    }
    var queryItems = component.queryItems ?? []
    queryItems.append(URLQueryItem(name: "crop", value: "entropy"))
    queryItems.append(URLQueryItem(name: "q", value: "\(quality)"))
    queryItems.append(URLQueryItem(name: "w", value: "\(size)"))
    queryItems.append(URLQueryItem(name: "fm", value: "jpg"))
    component.queryItems = queryItems
    return component.url
  }
}

// MARK: - ImageURL.Size

extension ImageURL {
  enum Size: Int {
    case fhd = 1080
    case hd = 720
    case sd = 480
    case low = 360

    var quality: Int {
      switch self {
      case .fhd, .hd:
        return 85
      case .sd:
        return 80
      case .low:
        return 75
      }
    }
  }
}

// MARK: - ImageURL (Decodable)

extension ImageURL: Decodable {
  enum CodingKeys: String, CodingKey {
    case raw
    case full
    case s3 = "small_s3"
  }
}

// MARK: - ImageURL (Preview)

#if DEBUG

extension ImageURL {
  static let preview = ImageURL(
    raw: URL(string: "https://images.unsplash.com/photo-1592029383200-73fb26a5b925?ixlib=rb-4.1.0")!,
    full: URL(string: "https://images.unsplash.com/photo-1592029383200-73fb26a5b925?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
    s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1592029383200-73fb26a5b925")!
  )
}

#endif
