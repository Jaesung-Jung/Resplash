//
//  Featured.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import Foundation

struct Featured: Identifiable {
  let id: String
  let title: String
  let items: [Item]
}

// MARK: - Featured.Item

extension Featured {
  struct Item {
    let title: String
    let imageCount: Int
    let coverImage: ImageAsset
  }
}

// MARK: - Featured (Hashable)

extension Featured: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - Featured (Decodable)

extension Featured: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "slug"
    case title
    case items = "children"
  }
}

// MARK: - Featured.Item (Decodable)

extension Featured.Item: Decodable {
  enum CodingKeys: String, CodingKey {
    case title
    case imageCount = "photos_count"
    case coverImage = "cover_photo"
  }
}
