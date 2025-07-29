//
//  Trend.swift
//  Resplash
//
//  Created by 정재성 on 7/29/25.
//

import Foundation

// MARK: - Trend

struct Trend: Identifiable {
  let id = UUID()
  let title: String
  let demand: Demand
  let thumbnailURL: ImageURL
  let growth: Int
  let results: Int
  let searchViews: Int
  let keywords: [Keyword]
}

// MARK: - Trend (Hashable)

extension Trend: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

// MARK: - Trend (Decodable)

extension Trend: Decodable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.title = try container.decode(String.self, forKey: "category")
    self.demand = try container.decode(Demand.self, forKey: "demand")

    let thumbContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "thumb")
    self.thumbnailURL = try thumbContainer.decode(ImageURL.self, forKey: "urls")

    self.growth = try container.decode(Int.self, forKey: "growth")
    self.results = try container.decode(Int.self, forKey: "results")
    self.searchViews = try container.decode(Int.self, forKey: "search_views")
    self.keywords = try container.decode([Keyword].self, forKey: "top_keywords")
  }
}

// MARK: - Trend.Demand

extension Trend {
  enum Demand: String, Decodable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
  }
}

// MARK: - Trend.Keyword

extension Trend {
  struct Keyword: Identifiable {
    let id = UUID()
    let title: String
    let demand: Demand
    let thumbnailURL: ImageURL
    let growth: Int
    let results: Int
    let searchViews: Int
  }
}

// MARK: - Trend.Keyword (Hashable)

extension Trend.Keyword: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

// MARK: - Trend.Keyword (Decodable)

extension Trend.Keyword: Decodable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.title = try container.decode(String.self, forKey: "keyword")
    self.demand = try container.decode(Trend.Demand.self, forKey: "demand")

    let thumbContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "thumb")
    self.thumbnailURL = try thumbContainer.decode(ImageURL.self, forKey: "urls")

    self.growth = try container.decode(Int.self, forKey: "growth")
    self.results = try container.decode(Int.self, forKey: "results")
    self.searchViews = try container.decode(Int.self, forKey: "search_views")
  }
}

// MARK: - Trend (Preview)

#if DEBUG

extension Trend {
  static let preview = Trend(
    title: "우주/천문학",
    demand: .high,
    thumbnailURL: .preview,
    growth: 1161,
    results: 684_238,
    searchViews: 3_545_366,
    keywords: [
      Trend.Keyword(
        title: "천문학",
        demand: .high,
        thumbnailURL: .preview,
        growth: 4300,
        results: 37_782,
        searchViews: 252_555
      ),
      Trend.Keyword(
        title: "별자리",
        demand: .medium,
        thumbnailURL: .preview,
        growth: 25,
        results: 472,
        searchViews: 87_509
      )
    ]
  )
}

#endif
