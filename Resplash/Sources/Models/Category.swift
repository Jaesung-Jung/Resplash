//
//  Category.swift
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

struct Category: Identifiable {
  let id: UUID
  let slug: String
  let title: String
  let items: [Item]
}

// MARK: - Category.Item

extension Category {
  struct Item: Identifiable {
    let id: UUID
    let slug: String
    let redirect: String?

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
  init(from decoder: any Decoder) throws {
    self.id = UUID()

    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.slug = try container.decode(String.self, forKey: "slug")
    self.title = try container.decode(String.self, forKey: "title")
    self.items = try container.decode([Item].self, forKey: "children")
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
    self.id = UUID()

    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.redirect = try container.decodeIfPresent(String.self, forKey: "redirect")
    self.title = try container.decode(String.self, forKey: "title")
    self.subtitle = try container.decode(String.self, forKey: "subtitle")
    let count = try container.decode(Int.self, forKey: "photos_count")
    self.imageCount = (count + 99) / 100 * 100 // round up
    let coverImageContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "cover_photo")
    self.coverImageURL = try coverImageContainer.decode(ImageURL.self, forKey: "urls")

    let ancestry = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "ancestry")
    let subcategory = try ancestry.nestedContainer(keyedBy: StringCodingKey.self, forKey: "subcategory")
    self.slug = try subcategory.decode(String.self, forKey: "slug")
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
    id: UUID(),
    slug: "stock",
    title: "스톡 사진 및 이미지",
    items: [.preview]
  )
}

extension Category.Item {
  static let preview = Category.Item(
    id: UUID(),
    slug: "royalty-free",
    redirect: nil,
    title: "Royalty Free Images",
    subtitle: "309,100+ Stocks and Images",
    imageCount: 309_099,
    coverImageURL: ImageURL(
      raw: URL(string: "https://images.unsplash.com/photo-1612899326681-66508905b4ce?ixlib=rb-4.1.0")!,
      full: URL(string: "https://images.unsplash.com/photo-1612899326681-66508905b4ce?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
      s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1612899326681-66508905b4ce")!
    )
  )
}

#endif
