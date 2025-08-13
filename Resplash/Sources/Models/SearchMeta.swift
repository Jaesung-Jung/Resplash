//
//  SearchMeta.swift
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

struct SearchMeta: Sendable {
  let input: String
  let photos: Int
  let illustrations: Int
  let collections: Int
  let users: Int
  let relatedSearches: [String]
}

// MARK: - SearchMeta (Decodable)

extension SearchMeta: Decodable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.input = try container.decode(String.self, forKey: "input")
    self.photos = try container.decode(Int.self, forKey: "photos")
    self.illustrations = try container.decode(Int.self, forKey: "illustrations")
    self.collections = try container.decode(Int.self, forKey: "collections")
    self.users = try container.decode(Int.self, forKey: "users")

    struct RelatedSearch: Decodable {
      let title: String
    }
    let relatedSearches = try container.decode([RelatedSearch].self, forKey: "related_searches")
    self.relatedSearches = relatedSearches.map(\.title)
  }
}
