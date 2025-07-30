//
//  SearchSuggestion.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import Algorithms

struct SearchSuggestion {
  let suggestions: [String]
}

// MARK: - SearchSuggestion (Hashable)

extension SearchSuggestion: Hashable {
}

// MARK: - SearchSuggestion (Decodable)

extension SearchSuggestion: Decodable {
  init(from decoder: any Decoder) throws {
    struct Item: Decodable {
      let query: String
    }
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    let fuzzy = (try? container.decodeIfPresent([Item].self, forKey: "fuzzy")) ?? []
    let autocomplete = (try? container.decodeIfPresent([Item].self, forKey: "autocomplete")) ?? []
    let didYouMean = (try? container.decodeIfPresent([Item].self, forKey: "did_you_mean")) ?? []
    let queries = fuzzy.map(\.query)
      .appending(contentsOf: autocomplete.map(\.query))
      .appending(contentsOf: didYouMean.map(\.query))
      .uniqued()
    self.suggestions = Array(queries)
  }
}
