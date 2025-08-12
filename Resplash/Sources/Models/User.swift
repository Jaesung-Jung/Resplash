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

struct User: Identifiable {
  let id: String
  let userId: String
  let updatedAt: Date
  let forHire: Bool

  let name: String
  let bio: String?
  let location: String?
  let profileImageURL: ProfileImageURL

  let totalLikes: Int
  let totalCollections: Int
  let totalPhotos: Int
  let totalIllustrations: Int

  let socials: [Social]
  let shareLink: URL

  let imageURLs: [ImageURL]
}

// MARK: - User.ProfileImageURL

extension User {
  struct ProfileImageURL: Decodable {
    let small: URL
    let medium: URL
    let large: URL
  }
}

// MARK: - User.Social

extension User {
  enum Social {
    case twitter(String)
    case instagram(String)
    case portfolio(URL)
  }
}

// MARK: - User (Hashable)

extension User: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
  }
}

// MARK: - User (Decodable)

extension User: Decodable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.id = try container.decode(String.self, forKey: "id")
    self.userId = try container.decode(String.self, forKey: "username")
    self.updatedAt = try container.decode(Date.self, forKey: "updated_at")
    self.forHire = try container.decode(Bool.self, forKey: "for_hire")

    self.name = try container.decode(String.self, forKey: "name")
    self.bio = try container.decodeIfPresent(String.self, forKey: "bio")
    self.location = try container.decodeIfPresent(String.self, forKey: "location")
    self.profileImageURL = try container.decode(ProfileImageURL.self, forKey: "profile_image")

    self.totalLikes = try container.decode(Int.self, forKey: "total_likes")
    self.totalCollections = try container.decode(Int.self, forKey: "total_collections")
    self.totalPhotos = try container.decode(Int.self, forKey: "total_photos")
    self.totalIllustrations = try container.decode(Int.self, forKey: "total_illustrations")

    let socialContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "social")
    self.socials = try socialContainer.allKeys.compactMap {
      switch $0.stringValue {
      case "twitter_username":
        return try socialContainer.decodeIfPresent(String.self, forKey: $0).map { .twitter($0) }
      case "instagram_username":
        return try socialContainer.decodeIfPresent(String.self, forKey: $0).map { .instagram($0) }
      case "portfolio_url":
        return try socialContainer.decodeIfPresent(URL.self, forKey: $0).map { .portfolio($0) }
      default:
        return nil
      }
    }

    let linkContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "links")
    self.shareLink = try linkContainer.decode(URL.self, forKey: "html")

    do {
      var photosContainer = try container.nestedUnkeyedContainer(forKey: "photos")
      var imageURLs: [ImageURL] = []
      if let count = photosContainer.count {
        imageURLs.reserveCapacity(count)
      }
      while !photosContainer.isAtEnd {
        let nestedContainer = try photosContainer.nestedContainer(keyedBy: StringCodingKey.self)
        imageURLs.append(try nestedContainer.decode(ImageURL.self, forKey: "urls"))
      }
      self.imageURLs = imageURLs
    } catch {
      self.imageURLs = []
    }
  }
}

// MARK: - User (Preview)

#if DEBUG

extension User {
  static let preview = User(
    id: "hHagXXIc3vU",
    userId: "sumup",
    updatedAt: .now,
    forHire: true,
    name: "SumUp",
    bio: "Developing tools & technology to help business owners around the world thrive.",
    location: "LA",
    profileImageURL: ProfileImageURL(
      small: URL(string: "https://images.unsplash.com/profile-1668694018296-888e51022d71image?ixlib=rb-4.1.0&crop=faces&fit=crop&w=32&h=32")!,
      medium: URL(string: "https://images.unsplash.com/profile-1668694018296-888e51022d71image?ixlib=rb-4.1.0&crop=faces&fit=crop&w=64&h=64")!,
      large: URL(string: "https://images.unsplash.com/profile-1668694018296-888e51022d71image?ixlib=rb-4.1.0&crop=faces&fit=crop&w=128&h=128")!
    ),
    totalLikes: 27_920,
    totalCollections: 2582,
    totalPhotos: 194_501,
    totalIllustrations: 4958,
    socials: [
      .instagram("sumup"),
      .twitter("piensaenpixel"),
      .portfolio(URL(string: "https://api.unsplash.com/users/piensaenpixel/portfolio")!)
    ],
    shareLink: URL(string: "https://unsplash.com/@sumup")!,
    imageURLs: [
      .preview,
      .preview
    ]
  )
}

#endif
