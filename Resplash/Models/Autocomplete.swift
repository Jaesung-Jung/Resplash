//
//  Autocomplete.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

struct Autocomplete: Identifiable {
  @inlinable var id: String { query }
  let query: String
  let priority: Int
}

// MARK: - Autocomplete (Hashable)

extension Autocomplete: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(query)
  }
}

// MARK: - Autocomplete (Decodable)

extension Autocomplete: Decodable {
}
