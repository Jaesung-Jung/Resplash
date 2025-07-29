//
//  Trend.swift
//  Resplash
//
//  Created by 정재성 on 7/29/25.
//

// MARK: - Trend

struct Trend {
  let title: String
  let demand: Demand
  let thumbnailURL: ImageURL
  let growth: Int
  let results: Int
  let searchViews: Int
  let keywords: [Keyword]
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
  struct Keyword {
    let title: String
    let demand: Demand
    let thumbnailURL: ImageURL
    let growth: Int
    let results: Int
    let searchViews: Int
  }
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
