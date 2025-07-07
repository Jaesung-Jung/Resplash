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
  case featured
  case photos(Int)
  case illustrations(Int)
  case collections(MediaType, Int)
  case autocomplete(String)
}

// MARK: - UnsplashAPI (TargetType)

extension UnsplashAPI: TargetType {
  typealias Method = Moya.Method

  var baseURL: URL { URL(string: "https://unsplash.com")! }

  var path: String {
    switch self {
    case .topics:
      return "napi/topics"
    case .featured:
      return "napi/landing_pages/featured"
    case .photos:
      return "napi/photos"
    case .illustrations:
      return "napi/illustrations"
    case .collections:
      return "napi/collections"
    case .autocomplete(let query):
      return "nautocomplete/\(query)"
    }
  }

  var task: Task {
    switch self {
    case .photos(let page), .illustrations(let page):
      return .requestParameters(
        parameters: ["page": page, "per_page": 30],
        encoding: URLEncoding.default
      )
    case .collections(let mediaType, let page):
      let assetType: String = switch mediaType {
      case .photo:
        "photos"
      case .illustration:
        "illustrations"
      }
      return .requestParameters(
        parameters: ["asset_type": assetType, "page": page, "per_page": 30],
        encoding: URLEncoding.default
      )
    case .topics, .featured, .autocomplete:
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
    case .featured:
      return file("featured") ?? object([])
    case .photos(let page):
      return file("photos_\(page)") ?? object([])
    case .illustrations(let page):
      return file("illustrations_\(page)") ?? object([])
    case .collections(let mediaType, let page):
      return file("\(mediaType.rawValue)_collections_\(page)") ?? object([])
    case .autocomplete:
      return file("autocomplete") ?? object([])
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
