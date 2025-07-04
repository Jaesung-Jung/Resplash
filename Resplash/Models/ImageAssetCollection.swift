//
//  ImageAssetCollection.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import Foundation

struct ImageAssetCollection: Identifiable {
  let id: String
  let updatedAt: Date

  let title: String
  let previewImages: [PreviewImageAsset]
  let totalImages: Int

  let user: User
  let shareLink: URL
}

// MARK: - ImageAssetCollection (Hashable)

extension ImageAssetCollection: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
  }
}

// MARK: - ImageAssetCollection (Decodable)

extension ImageAssetCollection: Decodable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.id = try container.decode(String.self, forKey: "id")
    self.updatedAt = try container.decode(Date.self, forKey: "updated_at")

    self.title = try container.decode(String.self, forKey: "title")
    self.previewImages = try container.decode([PreviewImageAsset].self, forKey: "previewImages")
    self.totalImages = try container.decode(Int.self, forKey: "totalImages")

    self.user = try container.decode(User.self, forKey: "user")
    let linkContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "links")
    self.shareLink = try linkContainer.decode(URL.self, forKey: "html")
  }
}
