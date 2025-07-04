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
  case photos(Int)
  case illustrations(Int)
  case autocomplete(String)
}

// MARK: - UnsplashAPI (TargetType)

extension UnsplashAPI: TargetType {
  typealias Method = Moya.Method

  var baseURL: URL { URL(string: "https://unsplash.com")! }

  var path: String {
    switch self {
    case .photos:
      return "napi/photos"
    case .illustrations:
      return "napi/illustrations"
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
    case .autocomplete:
      return .requestPlain
    }
  }

  var method: Method { .get }

  var headers: [String: String]? { nil }
}
