//
//  ImageAsset.swift
//  Resplash
//
//  Created by 정재성 on 7/3/25.
//

import Foundation

struct ImageAsset: Identifiable {
  let id: String
  let slug: String
  let createdAt: Date
  let updatedAt: Date
  let type: MediaType
  let isPremium: Bool

  let description: String?
  let likes: Int

  let width: Int
  let height: Int
  let color: String
  let url: ImageURL

  let user: User
  let shareLink: URL
}

// MARK: - ImageAsset (Hashable)

extension ImageAsset: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
  }
}

// MARK: - ImageAsset (Decodable)

extension ImageAsset: Decodable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.id = try container.decode(String.self, forKey: "id")
    self.slug = try container.decode(String.self, forKey: "slug")
    self.createdAt = try container.decode(Date.self, forKey: "created_at")
    self.updatedAt = try container.decode(Date.self, forKey: "updated_at")
    self.type = try container.decode(MediaType.self, forKey: "asset_type")
    self.isPremium = try container.decodeIfPresent(Bool.self, forKey: "premium") ?? false

    let description = try container.decodeIfPresent(String.self, forKey: "description")
    let altDescription = try container.decodeIfPresent(String.self, forKey: "alt_description")
    self.description = description ?? altDescription
    self.likes = try container.decode(Int.self, forKey: "likes")

    self.width = try container.decode(Int.self, forKey: "width")
    self.height = try container.decode(Int.self, forKey: "height")
    self.color = try container.decode(String.self, forKey: "color")
    self.url = try container.decode(ImageURL.self, forKey: "urls")

    self.user = try container.decode(User.self, forKey: "user")
    let linkContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "links")
    self.shareLink = try linkContainer.decode(URL.self, forKey: "html")
  }
}

// MARK: - ImageAsset (Preview)

#if DEBUG

extension ImageAsset {
  static let preview = ImageAsset(
    id: "DIdhesLS07I",
    slug: "DIdhesLS07I",
    createdAt: .now,
    updatedAt: .now,
    type: .photo,
    isPremium: false,
    description: "Close-up of the SumUp Solo card reader, held by a store owner in a boutique setting. Designed for small businesses that want to accept contactless card and mobile payments with style and ease.",
    likes: 4920,
    width: 5196,
    height: 3464,
    color: "#a6a6a6",
    url: .preview,
    user: .preview,
    shareLink: URL(string: "https://unsplash.com/photos/DIdhesLS07I")!
  )
}

#endif
