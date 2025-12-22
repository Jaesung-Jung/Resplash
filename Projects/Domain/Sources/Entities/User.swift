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
  }
}

// MARK: - Unsplash.User.ProfileImageURL

extension Unsplash.User {
  @MemberwiseInit(.public)
  public struct ProfileImageURL: Sendable {
    public let small: URL
    public let medium: URL
    public let large: URL
  }
}

// MARK: - Unsplash.User.Social

extension Unsplash.User {
  public enum Social: Sendable {
    case twitter(String)
    case instagram(String)
    case paypal(String)
    case portfolio(URL)
  }
}
