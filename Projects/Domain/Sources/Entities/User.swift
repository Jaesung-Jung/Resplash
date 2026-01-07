//
//  User.swift
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

extension Unsplash {
  @MemberwiseInit(.public)
  public struct User: Identifiable, Hashable, Sendable {
    public let id: String
    public let userId: String
    public let updatedAt: Date
    public let forHire: Bool

    public let name: String
    public let bio: String?
    public let location: String?
    public let profileImageURL: Unsplash.User.ProfileImageURL

    public let totalLikes: Int
    public let totalCollections: Int
    public let totalPhotos: Int
    public let totalIllustrations: Int

    public let socials: [Unsplash.User.Social]
    public let shareLink: URL

    public let imageURLs: [Unsplash.ImageURL]

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }

    public func link(for social: Unsplash.User.Social) -> URL? {
      guard socials.contains(social) else {
        return nil
      }
      switch social {
      case .instagram(let name):
        return URL(string: "https://www.instagram.com/\(name)")
      case .twitter(let name):
        return URL(string: "https://x.com/\(name)")
      case .portfolio(let url):
        return url
      case .paypal(let email):
        var compoents = URLComponents(string: "https://www.paypal.com/donate")
        compoents?.queryItems = [
          URLQueryItem(name: "business", value: email),
          URLQueryItem(name: "item_name", value: "\(name) - Unsplash"),
          URLQueryItem(name: "currency_code", value: "USD")
        ]
        return compoents?.url
      }
    }
  }
}

// MARK: - Unsplash.User.ProfileImageURL

extension Unsplash.User {
  @MemberwiseInit(.public)
  public struct ProfileImageURL: Sendable {
    public let small: URL
    public let medium: URL
    public let large: URL
    public var raw: URL {
      guard var components = URLComponents(url: large, resolvingAgainstBaseURL: false) else {
        return large
      }
      components.queryItems = nil
      return components.url ?? large
    }
  }
}

// MARK: - Unsplash.User.Social

extension Unsplash.User {
  public enum Social: Hashable, Comparable, Sendable {
    case instagram(String)
    case twitter(String)
    case portfolio(URL)
    case paypal(String)

    var order: Int {
      switch self {
      case .instagram:
        return 0
      case .twitter:
        return 1
      case .portfolio:
        return 2
      case .paypal:
        return 3
      }
    }

    public static func < (lhs: Unsplash.User.Social, rhs: Unsplash.User.Social) -> Bool {
      lhs.order < rhs.order
    }
  }
}
