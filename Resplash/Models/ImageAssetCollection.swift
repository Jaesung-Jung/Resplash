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
    self.previewImages = try container.decode([PreviewImageAsset].self, forKey: "preview_photos")
    self.totalImages = try container.decode(Int.self, forKey: "total_photos")

    self.user = try container.decode(User.self, forKey: "user")
    let linkContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "links")
    self.shareLink = try linkContainer.decode(URL.self, forKey: "html")
  }
}

#if DEBUG

// MARK: - ImageAssetCollection Preview

extension ImageAssetCollection {
  static let preview = ImageAssetCollection(
    id: "vpXhLgGnoj0",
    updatedAt: .now,
    title: "Summer Backgrounds",
    previewImages: [
      PreviewImageAsset(
        id: "VrP25Libv",
        imageURL: ImageAssetURL(
          raw: URL(string: "https://plus.unsplash.com/premium_photo-1680608155016-3faa9cbdc236?ixlib=rb-4.1.0")!,
          full: URL(string: "https://plus.unsplash.com/premium_photo-1680608155016-3faa9cbdc236?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
          regular: URL(string: "https://plus.unsplash.com/premium_photo-1680608155016-3faa9cbdc236?ixlib=rb-4.1.0&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max")!,
          small: URL(string: "https://plus.unsplash.com/premium_photo-1680608155016-3faa9cbdc236?ixlib=rb-4.1.0&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max")!,
          thumb: URL(string: "https://plus.unsplash.com/premium_photo-1680608155016-3faa9cbdc236?ixlib=rb-4.1.0&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=200&fit=max")!,
          smallS3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/unsplash-premium-photos-production/premium_photo-1680608155016-3faa9cbdc236")!
        )
      ),
      PreviewImageAsset(
        id: "IfK3Mpo3I",
        imageURL: ImageAssetURL(
          raw: URL(string: "https://plus.unsplash.com/premium_photo-1700253458597-6729fbc52c67?ixlib=rb-4.1.0")!,
          full: URL(string: "https://plus.unsplash.com/premium_photo-1700253458597-6729fbc52c67?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
          regular: URL(string: "https://plus.unsplash.com/premium_photo-1700253458597-6729fbc52c67?ixlib=rb-4.1.0&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max")!,
          small: URL(string: "https://plus.unsplash.com/premium_photo-1700253458597-6729fbc52c67?ixlib=rb-4.1.0&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max")!,
          thumb: URL(string: "https://plus.unsplash.com/premium_photo-1700253458597-6729fbc52c67?ixlib=rb-4.1.0&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=200&fit=max")!,
          smallS3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/unsplash-premium-photos-production/premium_photo-1700253458597-6729fbc52c67")!
        )
      ),
      PreviewImageAsset(
        id: "hSmcIn4Fb",
        imageURL: ImageAssetURL(
          raw: URL(string: "https://plus.unsplash.com/premium_photo-1721830698195-ff1f7daa5ce5?ixlib=rb-4.1.0")!,
          full: URL(string: "https://plus.unsplash.com/premium_photo-1721830698195-ff1f7daa5ce5?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
          regular: URL(string: "https://plus.unsplash.com/premium_photo-1721830698195-ff1f7daa5ce5?ixlib=rb-4.1.0&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max")!,
          small: URL(string: "https://plus.unsplash.com/premium_photo-1721830698195-ff1f7daa5ce5?ixlib=rb-4.1.0&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max")!,
          thumb: URL(string: "https://plus.unsplash.com/premium_photo-1721830698195-ff1f7daa5ce5?ixlib=rb-4.1.0&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=200&fit=max")!,
          smallS3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/unsplash-premium-photos-production/premium_photo-1721830698195-ff1f7daa5ce5")!
        )
      )
    ],
    totalImages: 70,
    user: .preview,
    shareLink: URL(string: "https://unsplash.com/ko/%EC%BB%AC%EB%A0%89%EC%85%98/vpXhLgGnoj0/summer-backgrounds")!
  )
}

#endif
