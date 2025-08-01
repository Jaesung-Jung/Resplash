//
//  UnsplashAPI.swift
//  Resplash
//
//  Created by 정재성 on 7/3/25.
//

import Foundation
import Alamofire
import Moya

enum UnsplashAPI {
  case topics
  case categories
  case photos(page: Int, perPage: Int)
  case illustrations(page: Int, perPage: Int)
  case collections(mediaType: MediaType, page: Int, perPage: Int)
  case topicImages(topic: Topic, page: Int, perPage: Int)
  case collectionImages(collection: ImageAssetCollection, page: Int, perPage: Int)
  case categoryImages(category: Category.Item, page: Int, perPage: Int)
  case imageDetail(image: ImageAsset)
  case seriesImages(image: ImageAsset)
  case relatedImages(image: ImageAsset, page: Int, perPage: Int)
  case autocomplete(query: String)
  case search(query: String, page: Int, perPage: Int)
  case searchTrends(page: Int, perPage: Int)
  case searchMeta(query: String)
}

// MARK: - UnsplashAPI (TargetType)

extension UnsplashAPI: TargetType {
  typealias Method = Moya.Method

  var baseURL: URL { URL(string: "https://unsplash.com")! }

  var path: String {
    switch self {
    case .topics:
      return "napi/topics"
    case .categories:
      return "napi/landing_pages/featured"
    case .photos:
      return "napi/photos"
    case .illustrations:
      return "napi/illustrations"
    case .collections:
      return "napi/collections"
    case .topicImages(let topic, _, _):
      return "napi/topics/\(topic.slug)/photos"
    case .collectionImages(let collection, _, _):
      return "napi/collections/\(collection.id)/photos"
    case .categoryImages(let category, _, _):
      return "napi/landing_pages/images/stock/\(category.slug)"
    case .imageDetail(let image):
      return "napi/photos/\(image.slug)"
    case .seriesImages(let image):
      return "napi/photos/\(image.slug)/series"
    case .relatedImages(let image, _, _):
      return "napi/photos/\(image.slug)/related"
    case .autocomplete(let query):
      return "nautocomplete/\(query)"
    case .search:
      return "napi/search/photos"
    case .searchTrends:
      return "napi/search_trends"
    case .searchMeta:
      return "napi/search/meta"
    }
  }

  var task: Task {
    switch self {
    case .photos(let page, let perPage), .illustrations(let page, let perPage), .topicImages(_, let page, let perPage), .relatedImages(_, let page, let perPage):
      return .requestParameters(
        parameters: ["page": page, "per_page": perPage],
        encoding: URLEncoding.default
      )
    case .topics:
      return .requestParameters(
        parameters: ["per_page": 50],
        encoding: URLEncoding.default
      )
    case .collections(let mediaType, let page, let perPage):
      let assetType: String = switch mediaType {
      case .photo:
        "photos"
      case .illustration:
        "illustrations"
      }
      return .requestParameters(
        parameters: ["asset_type": assetType, "page": page, "per_page": perPage],
        encoding: URLEncoding.default
      )
    case .collectionImages(let collection, let page, let perPage):
      return .requestParameters(
        parameters: ["page": page, "per_page": perPage, "share_key": collection.shareKey],
        encoding: URLEncoding.default
      )
    case .categoryImages(_, let page, let perPage):
      return .requestParameters(
        parameters: ["page": page, "per_page": perPage],
        encoding: URLEncoding.default
      )
    case .seriesImages:
      return .requestParameters(
        parameters: ["limit": 10],
        encoding: URLEncoding.default
      )
    case .search(let query, let page, let perPage):
      return .requestParameters(
        parameters: ["query": query, "page": page, "per_page": perPage],
        encoding: URLEncoding.default
      )
    case .searchTrends(let page, let perPage):
      return .requestParameters(
        parameters: ["page": page, "per_page": perPage],
        encoding: URLEncoding.default
      )
    case .searchMeta(let query):
      return .requestParameters(
        parameters: ["query": query],
        encoding: URLEncoding.default
      )
    case .categories, .imageDetail, .autocomplete:
      return .requestPlain
    }
  }

  var method: Method { .get }

  var headers: [String: String]? { nil }
}

#if DEBUG

// MARK: - UnsplashAPI (Sample)

extension UnsplashAPI {
  var sampleData: Data {
    switch self {
    case .topics:
      return file("topics") ?? object([])
    case .categories:
      return file("categories") ?? object([])
    case .photos(let page, _):
      return file("photos_\(page)") ?? object([])
    case .illustrations(let page, _):
      return file("illustrations_\(page)") ?? object([])
    case .collections(let mediaType, let page, _):
      return file("\(mediaType.rawValue)_collections_\(page)") ?? object([])
    case .topicImages(_, let page, _):
      return file("topic_images_\(page)") ?? object([])
    case .collectionImages(_, let page, _):
      return file("collection_images_\(page)") ?? object([])
    case .categoryImages(_, let page, let perPage):
      return file("") ?? object([])
    case .imageDetail:
      return file("photo_detail_\(Int.random(in: 1...2))") ?? object([:])
    case .seriesImages:
      return file("photo_series") ?? object([])
    case .relatedImages(_, let page, _):
      return file("photo_related_\(page)") ?? object([:])
    case .autocomplete:
      return file("autocomplete") ?? object([])
    case .search(_, let page, _):
      return file("") ?? object([])
    case .searchTrends(let page, _):
      return file("search_trend_\(page)") ?? object([])
    case .searchMeta:
      return file("search_meta") ?? object([])
    }
  }

  private func file(_ name: String) -> Data? {
    Bundle.main
      .url(forResource: name, withExtension: "json")
      .flatMap { try? Data(contentsOf: $0) }
  }

  private func object(_ object: Any) -> Data {
    let data = try? JSONSerialization.data(withJSONObject: object)
    return data ?? Data()
  }
}

#endif
