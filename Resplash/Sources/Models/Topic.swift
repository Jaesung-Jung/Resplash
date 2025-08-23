//
//  Topic.swift
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

struct Topic: Identifiable, Sendable {
  let id: String
  let slug: String
  let visibility: Visibility
  let owners: [User]

  let title: String
  let description: String
  let mediaTypes: Set<MediaType>
  let coverImage: ImageAsset

  let imageCount: Int
  let shareLink: URL
}

// MARK: - Topic.Visibility

extension Topic {
  enum Visibility: String, Decodable {
    case featured
    case visible
  }
}

// MARK: - Topic (Hashable)

extension Topic: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

// MARK: - Topic (Decodable)

extension Topic: Decodable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.id = try container.decode(String.self, forKey: "id")
    self.slug = try container.decode(String.self, forKey: "slug")
    self.visibility = try container.decode(Visibility.self, forKey: "visibility")
    self.owners = try container.decode([User].self, forKey: "owners")
    self.title = try container.decode(String.self, forKey: "title")
    self.description = try container.decode(String.self, forKey: "description")
    self.mediaTypes = try container.decode(Set<MediaType>.self, forKey: "media_types")
    self.coverImage = try container.decode(ImageAsset.self, forKey: "cover_photo")
    self.imageCount = try container.decode(Int.self, forKey: "total_photos")
    let linkContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "links")
    self.shareLink = try linkContainer.decode(URL.self, forKey: "html")
  }
}

// MARK: - Topic (Preview)

#if DEBUG

extension Topic {
  static let preview = Topic(
    id: "bo8jQKT",
    slug: "wallpapers",
    visibility: .featured,
    owners: [.preview],
    title: "Wallpapers",
    description: "From epic drone shots to inspiring moments in nature — enjoy the best background for your desktop or mobile.",
    mediaTypes: [.photo],
    coverImage: .preview,
    imageCount: 16_519,
    shareLink: URL(string: "https://unsplash.com/ko/t/wallpapers")!
  )
}

#endif
