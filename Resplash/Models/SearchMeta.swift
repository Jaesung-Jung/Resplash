//
//  SearchMeta.swift
//  Resplash
//
//  Created by 정재성 on 8/1/25.
//

struct SearchMeta {
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
