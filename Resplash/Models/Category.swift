//
//  Category.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import Foundation

struct Category: Identifiable {
  let id = UUID()
  let slug: String
  let title: String
  let items: [Item]
}

// MARK: - Category.Item

extension Category {
  struct Item: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageCount: Int
    let coverImageURL: ImageURL
  }
}

// MARK: - Category (Hashable)

extension Category: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

// MARK: - Category (Decodable)

extension Category: Decodable {
  enum CodingKeys: String, CodingKey {
    case slug
    case title
    case items = "children"
  }
}

// MARK: - Category.Item (Hashable)

extension Category.Item: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

// MARK: - Category.Item (Decodable)

extension Category.Item: Decodable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.title = try container.decode(String.self, forKey: "title")
    self.subtitle = try container.decode(String.self, forKey: "subtitle")
    let count = try container.decode(Int.self, forKey: "photos_count")
    self.imageCount = (count + 99) / 100 * 100 // round up
    let coverImageContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "cover_photo")
    self.coverImageURL = try coverImageContainer.decode(ImageURL.self, forKey: "urls")
  }
}

extension Category: CustomStringConvertible {
  var description: String { title }
}

extension Category.Item: CustomStringConvertible {
  var description: String { title }
}

// MARK: - Category (Preview)

#if DEBUG

extension Category {
  static let preview = Category(
    slug: "stock",
    title: "스톡 사진 및 이미지",
    items: [.preview]
  )
}

extension Category.Item {
  static let preview = Category.Item(
    title: "로열티 프리 이미지",
    subtitle: "309,100+ 스톡 사진 및 이미지",
    imageCount: 309_099,
    coverImageURL: ImageURL(
      raw: URL(string: "https://images.unsplash.com/photo-1612899326681-66508905b4ce?ixlib=rb-4.1.0")!,
      full: URL(string: "https://images.unsplash.com/photo-1612899326681-66508905b4ce?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
      s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1612899326681-66508905b4ce")!
    )
  )
}

#endif
