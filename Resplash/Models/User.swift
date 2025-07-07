//
//  User.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import Foundation

struct User: Identifiable {
  let id: String
  let userId: String
  let updatedAt: Date

  let name: String
  let bio: String?
  let location: String?
  let imageURL: ImageURL

  let totalLikes: Int
  let totalCollections: Int
  let totalPhotos: Int
  let totalIllustrations: Int

  let socials: [Social]
  let shareLink: URL
}

// MARK: - User.ImageURL

extension User {
  struct ImageURL: Decodable {
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

    self.name = try container.decode(String.self, forKey: "name")
    self.bio = try container.decodeIfPresent(String.self, forKey: "bio")
    self.location = try container.decodeIfPresent(String.self, forKey: "location")
    self.imageURL = try container.decode(ImageURL.self, forKey: "profile_image")

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
  }
}

// MARK: - User (Preview)

#if DEBUG

extension User {
  static let preview = User(
    id: "hHagXXIc3vU",
    userId: "sumup",
    updatedAt: .now,
    name: "SumUp",
    bio: "Developing tools & technology to help business owners around the world thrive.",
    location: "LA",
    imageURL: ImageURL(
      small: URL(string: "https://images.unsplash.com/profile-1725878289869-4e679a729355image?ixlib=rb-4.1.0&crop=faces&fit=crop&w=32&h=32")!,
      medium: URL(string: "https://images.unsplash.com/profile-1725878289869-4e679a729355image?ixlib=rb-4.1.0&crop=faces&fit=crop&w=64&h=64")!,
      large: URL(string: "https://images.unsplash.com/profile-1725878289869-4e679a729355image?ixlib=rb-4.1.0&crop=faces&fit=crop&w=128&h=128")!
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
    shareLink: URL(string: "https://unsplash.com/@sumup")!
  )
}

#endif
