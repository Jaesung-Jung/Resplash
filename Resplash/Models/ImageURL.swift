//
//  ImageURL.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

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
