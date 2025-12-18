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

@MemberwiseInit(.public)
public struct User {
  public let id: String
  public let userId: String
  public let updatedAt: Date
  public let forHire: Bool

  public let name: String
  public let bio: String?
  public let location: String?
  public let profileImageURL: ProfileImageURL

  public let totalLikes: Int
  public let totalCollections: Int
  public let totalPhotos: Int
  public let totalIllustrations: Int

  public let socials: [Social]
  public let shareLink: URL

  public let imageURLs: [ImageURL]
}

extension User: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
  }
}

extension User: Identifiable {
}

extension User: Sendable {
}

// MARK: - User.ProfileImageURL

extension User {
  @MemberwiseInit(.public)
  public struct ProfileImageURL {
    public let small: URL
    public let medium: URL
    public let large: URL
  }
}

extension User.ProfileImageURL: Sendable {
}

// MARK: - User.Social

extension User {
  public enum Social {
    case twitter(String)
    case instagram(String)
    case paypal(String)
    case portfolio(URL)
  }
}

extension User.Social: Sendable {
}
