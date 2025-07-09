//
//  Topic.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

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
    imageCount: 16519
  )
}

#endif
