//
//  UnsplashAPI.swift
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

import Foundation
import Alamofire

extension Unsplash {
  enum API {
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
    case searchPhotos(query: String, page: Int, perPage: Int)
    case searchIllustrations(query: String, page: Int, perPage: Int)
    case searchCollections(query: String, page: Int, perPage: Int)
    case searchUsers(query: String, page: Int, perPage: Int)
    case searchTrends(page: Int, perPage: Int)
    case searchMeta(query: String)
  }
}

// MARK: - Unsplash.API

extension Unsplash.API {
  var baseURL: URL { URL(string: "https://unsplash.com")! }

  var method: HTTPMethod { .get }

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
    case .searchPhotos:
      return "napi/search/photos"
    case .searchIllustrations:
      return "napi/search/illustrations"
    case .searchCollections:
      return "napi/search/collections"
    case .searchUsers:
      return "napi/search/users"
    case .searchTrends:
      return "napi/search_trends"
    case .searchMeta:
      return "napi/search/meta"
    }
  }

  var parameters: Parameters? {
    switch self {
    case .topics:
      ["per_page": 50]
    case .photos(let page, let perPage):
      ["page": page, "per_page": perPage]
    case .illustrations(let page, let perPage):
      ["page": page, "per_page": perPage]
    case .collections(.photo, let page, let perPage):
      ["asset_type": "photos", "page": page, "per_page": perPage]
    case .collections(.illustration, let page, let perPage):
      ["asset_type": "illustrations", "page": page, "per_page": perPage]
    case .topicImages(_, let page, let perPage):
      ["page": page, "per_page": perPage]
    case .collectionImages(let collection, let page, let perPage):
      ["page": page, "per_page": perPage, "share_key": collection.shareKey]
    case .categoryImages(_, let page, let perPage):
      ["page": page, "per_page": perPage]
    case .seriesImages:
      ["limit": 10]
    case .relatedImages(_, let page, let perPage):
      ["page": page, "per_page": perPage]
    case .searchPhotos(let query, let page, let perPage):
      ["query": query, "page": page, "per_page": perPage]
    case .searchIllustrations(let query, let page, let perPage):
      ["query": query, "page": page, "per_page": perPage]
    case .searchCollections(let query, let page, let perPage):
      ["query": query, "page": page, "per_page": perPage]
    case .searchUsers(let query, let page, let perPage):
      ["query": query, "page": page, "per_page": perPage]
    case .searchTrends(let page, let perPage):
      ["page": page, "per_page": perPage]
    case .searchMeta(let query):
      ["query": query]
    default:
      nil
    }
  }

  var encoding: any ParameterEncoding { URLEncoding.default }

  @inlinable func makeURL() -> URL { baseURL.appending(path: path) }
}

#if DEBUG

// MARK: - Unsplash.API (Sample)

extension Unsplash.API {
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
    case .categoryImages(_, let page, _):
      return file("category_images_\(page)") ?? object([])
    case .imageDetail:
      return file("photo_detail_\(Int.random(in: 1...2))") ?? object([:])
    case .seriesImages:
      return file("photo_series") ?? object([])
    case .relatedImages(_, let page, _):
      return file("photo_related_\(page)") ?? object([:])
    case .autocomplete:
      return file("autocomplete") ?? object([])
    case .searchPhotos(_, let page, _):
      return file("search_photos_\(page)") ?? object([])
    case .searchIllustrations(_, let page, _):
      return file("search_illustrations_\(page)") ?? object([])
    case .searchCollections(_, let page, _):
      return file("search_collections_\(page)") ?? object([])
    case .searchUsers(_, let page, _):
      return file("search_users_\(page)") ?? object([])
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
