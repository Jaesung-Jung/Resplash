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
import MemberwiseInit

@MemberwiseInit(.public)
public struct ImageURL {
  public let raw: URL
  public let full: URL
  public let s3: URL

  @inlinable public var fhd: URL? { url(.fhd) }
  @inlinable public var hd: URL? { url(.hd) }
  @inlinable public var sd: URL? { url(.sd) }
  @inlinable public var low: URL? { url(.low) }

  @usableFromInline
  func url(_ size: Size) -> URL? {
    url(size.rawValue, quality: size.quality)
  }

  @usableFromInline
  func url(size: CGFloat, quality: Int = 80) -> URL? {
    url(Int(size), quality: quality)
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

extension ImageURL: Equatable {
}

extension ImageURL: Sendable {
}

// MARK: - ImageURL.Size

extension ImageURL {
  public enum Size: Int {
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

extension ImageURL.Size: Sendable {
}
