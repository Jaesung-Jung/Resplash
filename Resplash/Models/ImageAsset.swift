//
//  ImageAsset.swift
//  Resplash
//
//  Created by 정재성 on 7/3/25.
//

import Foundation

struct ImageAsset: Identifiable {
  let id: String
  let createdAt: Date
  let updatedAt: Date
  let type: MediaType
  let isPremium: Bool

  let description: String?
  let likes: Int

  let width: Int
  let height: Int
  let color: String
  let imageURL: ImageAssetURL

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
    self.createdAt = try container.decode(Date.self, forKey: "created_at")
    self.updatedAt = try container.decode(Date.self, forKey: "updated_at")
    self.type = try container.decode(MediaType.self, forKey: "asset_type")
    self.isPremium = try container.decode(Bool.self, forKey: "premium")

    let description = try container.decodeIfPresent(String.self, forKey: "description")
    let altDescription = try container.decodeIfPresent(String.self, forKey: "alt_description")
    self.description = description ?? altDescription
    self.likes = try container.decode(Int.self, forKey: "likes")

    self.width = try container.decode(Int.self, forKey: "width")
    self.height = try container.decode(Int.self, forKey: "height")
    self.color = try container.decode(String.self, forKey: "color")
    self.imageURL = try container.decode(ImageAssetURL.self, forKey: "urls")

    self.user = try container.decode(User.self, forKey: "user")
    let linkContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "links")
    self.shareLink = try linkContainer.decode(URL.self, forKey: "html")
  }
}
