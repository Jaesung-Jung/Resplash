//
//  ImageAssetCollection.swift
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

struct ImageAssetCollection: Identifiable, Sendable {
  let id: String
  let shareKey: String
  let updatedAt: Date

  let title: String
  let imageURLs: [ImageURL]
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
    self.shareKey = try container.decode(String.self, forKey: "share_key")
    self.updatedAt = try container.decode(Date.self, forKey: "updated_at")

    self.title = try container.decode(String.self, forKey: "title")
    self.totalImages = try container.decode(Int.self, forKey: "total_photos")

    self.user = try container.decode(User.self, forKey: "user")
    let linkContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "links")
    self.shareLink = try linkContainer.decode(URL.self, forKey: "html")

    do {
      var previewContrainer = try container.nestedUnkeyedContainer(forKey: "preview_photos")
      var previewImages: [ImageURL] = []
      if let count = previewContrainer.count {
        previewImages.reserveCapacity(count)
      }
      while !previewContrainer.isAtEnd {
        let nestedContainer = try previewContrainer.nestedContainer(keyedBy: StringCodingKey.self)
        previewImages.append(try nestedContainer.decode(ImageURL.self, forKey: "urls"))
      }
      self.imageURLs = previewImages
    } catch {
      self.imageURLs = []
    }
  }
}

#if DEBUG

// MARK: - ImageAssetCollection Preview

extension ImageAssetCollection {
  static let preview = ImageAssetCollection(
    id: "vpXhLgGnoj0",
    shareKey: "f3993589b33f306668e33943911a8fd1",
    updatedAt: .now,
    title: "Summer Backgrounds",
    imageURLs: [
      ImageURL(
        raw: URL(string: "https://plus.unsplash.com/premium_photo-1680608155016-3faa9cbdc236?ixlib=rb-4.1.0")!,
        full: URL(string: "https://plus.unsplash.com/premium_photo-1680608155016-3faa9cbdc236?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/unsplash-premium-photos-production/premium_photo-1680608155016-3faa9cbdc236")!
      ),
      ImageURL(
        raw: URL(string: "https://plus.unsplash.com/premium_photo-1700253458597-6729fbc52c67?ixlib=rb-4.1.0")!,
        full: URL(string: "https://plus.unsplash.com/premium_photo-1700253458597-6729fbc52c67?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/unsplash-premium-photos-production/premium_photo-1700253458597-6729fbc52c67")!
      ),
      ImageURL(
        raw: URL(string: "https://plus.unsplash.com/premium_photo-1721830698195-ff1f7daa5ce5?ixlib=rb-4.1.0")!,
        full: URL(string: "https://plus.unsplash.com/premium_photo-1721830698195-ff1f7daa5ce5?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/unsplash-premium-photos-production/premium_photo-1721830698195-ff1f7daa5ce5")!
      )
    ],
    totalImages: 70,
    user: .preview,
    shareLink: URL(string: "https://unsplash.com/ko/%EC%BB%AC%EB%A0%89%EC%85%98/vpXhLgGnoj0/summer-backgrounds")!
  )
}

#endif
