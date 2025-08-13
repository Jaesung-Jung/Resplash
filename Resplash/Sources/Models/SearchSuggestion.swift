//
//  SearchSuggestion.swift
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

import Algorithms

struct SearchSuggestion: Sendable {
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
    let queries = (fuzzy.map(\.query) + autocomplete.map(\.query) + didYouMean.map(\.query)).uniqued()
    self.suggestions = Array(queries)
  }
}
