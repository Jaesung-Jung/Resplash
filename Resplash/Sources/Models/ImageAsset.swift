//
//  ImageAsset.swift
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

struct ImageAsset: Identifiable, Sendable {
  let id: String
  let slug: String
  let createdAt: Date
  let updatedAt: Date
  let type: MediaType
  let isPremium: Bool

  let description: String?
  let likes: Int

  let width: CGFloat
  let height: CGFloat
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

    self.width = try container.decode(CGFloat.self, forKey: "width")
    self.height = try container.decode(CGFloat.self, forKey: "height")
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
    width: 9972,
    height: 9972,
    color: "#a6a6a6",
    url: .preview,
    user: .preview,
    shareLink: URL(string: "https://unsplash.com/photos/DIdhesLS07I")!
  )

  static let preview2 = ImageAsset(
    id: "y3AuJts5x1Y",
    slug: "화이트-포르쉐-911의-리어-엔드가-보인다-y3AuJts5x1Y",
    createdAt: .now,
    updatedAt: .now,
    type: .photo,
    isPremium: false,
    description: "Porsche 911T",
    likes: 4920,
    width: 6336,
    height: 9504,
    color: "#f3f3f3",
    url: ImageURL(
      raw: URL(string: "https://images.unsplash.com/photo-1750210955902-ce0e71765fb1?ixid=M3wxMjA3fDB8MXxhbGx8MXx8fHx8fHx8MTc1Njk0NTgxOXw&ixlib=rb-4.1.0")!,
      full: URL(string: "https://images.unsplash.com/photo-1750210955902-ce0e71765fb1?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxMjA3fDB8MXxhbGx8MXx8fHx8fHx8MTc1Njk0NTgxOXw&ixlib=rb-4.1.0&q=85")!,
      s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1750210955902-ce0e71765fb1")!
    ),
    user: .preview,
    shareLink: URL(string: "https://unsplash.com/photos/DIdhesLS07I")!
  )
}

#endif
