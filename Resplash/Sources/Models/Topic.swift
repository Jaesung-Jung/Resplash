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

struct Topic: Identifiable {
  let id: String
  let slug: String
  let visibility: Visibility

  let title: String
  let description: String
  let mediaTypes: Set<MediaType>
  let coverImage: ImageAsset

  let imageCount: Int
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
  enum CodingKeys: String, CodingKey {
    case id
    case slug
    case visibility
    case title
    case description
    case mediaTypes = "media_types"
    case coverImage = "cover_photo"
    case imageCount = "total_photos"
  }
}

// MARK: - Topic (Preview)

#if DEBUG

extension Topic {
  static let preview = Topic(
    id: "bo8jQKT",
    slug: "wallpapers",
    visibility: .featured,
    title: "Wallpapers",
    description: "From epic drone shots to inspiring moments in nature — enjoy the best background for your desktop or mobile.",
    mediaTypes: [.photo],
    coverImage: .preview,
    imageCount: 16_519
  )
}

#endif
