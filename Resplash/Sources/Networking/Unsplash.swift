//
//  Unsplash.swift
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

struct Unsplash: Sendable {
  typealias RequestHandler = @Sendable (Session, API) async throws -> Data

  private let session: Session
  private let requestHandler: RequestHandler

  init(eventMonitors: [any EventMonitor] = [], requestHandler: RequestHandler? = nil) {
    self.session = Session(eventMonitors: eventMonitors)
    self.requestHandler = requestHandler ?? { session, api in
      let request = session.request(api.makeURL(), method: api.method, parameters: api.parameters, encoding: api.encoding)
      return try await request.validate().serializingData().value
    }
  }

  @inlinable func topics(for mediaType: MediaType) async throws -> [Topic] {
    try await request(.topics, to: [Topic].self)
      .filter { $0.mediaTypes.contains(mediaType) }
  }

  @inlinable func categories() async throws -> [Category] {
    try await request(.categories)
  }

  @inlinable func photos(page: Int) async throws -> Page<[ImageAsset]> {
    try await images(for: .photo, page: page)
  }

  @inlinable func illustrations(page: Int) async throws -> Page<[ImageAsset]> {
    try await images(for: .illustration, page: page)
  }

  @inlinable func images(for mediaType: MediaType, page: Int) async throws -> Page<[ImageAsset]> {
    let perPage = 30
    switch mediaType {
    case .photo:
      return try await request(.photos(page: page, perPage: perPage), page: page, perPage: perPage)
    case .illustration:
      return try await request(.illustrations(page: page, perPage: perPage), page: page, perPage: perPage)
    }
  }

  @inlinable func images(for topic: Topic, page: Int) async throws -> Page<[ImageAsset]> {
    let perPage = 30
    return try await request(.topicImages(topic: topic, page: page, perPage: perPage), page: page, perPage: perPage)
  }

  @inlinable func images(for collection: ImageAssetCollection, page: Int) async throws -> Page<[ImageAsset]> {
    let perPage = 30
    return try await request(.collectionImages(collection: collection, page: page, perPage: perPage), page: page, perPage: perPage)
  }

  @inlinable func images(for category: Category.Item, page: Int) async throws -> Page<[ImageAsset]> {
    let perPage = 30
    return try await request(.categoryImages(category: category, page: page, perPage: perPage), page: page, perPage: perPage, at: "photos")
  }

  @inlinable func collections(for mediaType: MediaType, page: Int) async throws -> Page<[ImageAssetCollection]> {
    let perPage = 30
    return try await request(.collections(mediaType: mediaType, page: page, perPage: perPage), page: page, perPage: perPage)
  }

  @inlinable func imageDetail(for image: ImageAsset) async throws -> ImageAssetDetail {
    return try await request(.imageDetail(image: image))
  }

  @inlinable func seriesImages(for image: ImageAsset) async throws -> [ImageAsset] {
    try await request(.seriesImages(image: image))
  }

  @inlinable func relatedImage(for image: ImageAsset, page: Int) async throws -> Page<[ImageAsset]> {
    let perPage = 20
    return try await request(.relatedImages(image: image, page: page, perPage: perPage), page: page, perPage: perPage, at: "results")
  }

  @inlinable func searchSuggestion(_ query: String) async throws -> SearchSuggestion {
    try await request(.autocomplete(query: query))
  }

  @inlinable func searchPhotos(_ query: String, page: Int) async throws -> Page<[ImageAsset]> {
    let perPage = 20
    return try await request(.searchPhotos(query: query, page: page, perPage: perPage), page: page, perPage: perPage, at: "results")
  }

  @inlinable func searchIllustrations(_ query: String, page: Int) async throws -> Page<[ImageAsset]> {
    let perPage = 20
    return try await request(.searchIllustrations(query: query, page: page, perPage: perPage), page: page, perPage: perPage, at: "results")
  }

  @inlinable func searchCollections(_ query: String, page: Int) async throws -> Page<[ImageAssetCollection]> {
    let perPage = 20
    return try await request(.searchCollections(query: query, page: page, perPage: perPage), page: page, perPage: perPage, at: "results")
  }

  @inlinable func searchUsers(_ query: String, page: Int) async throws -> Page<[User]> {
    let perPage = 20
    return try await request(.searchUsers(query: query, page: page, perPage: perPage), page: page, perPage: perPage, at: "results")
  }

  @inlinable func searchTrends() async throws -> [Trend] {
    // 2페이지 부터 응답속도 문제로 인해 1페이지만 요청
    try await request(.searchTrends(page: 1, perPage: 20))
  }

  @inlinable func searchMeta(_ query: String) async throws -> SearchMeta {
    try await request(.searchMeta(query: query))
  }
}

// MARK: - Unsplash (Private)

extension Unsplash {
  private func request<T: Decodable>(_ api: API, to type: T.Type = T.self, at keyPath: String? = nil) async throws -> T {
    let data = try await requestHandler(session, api)
    let decoder = JSONDecoder().then {
      $0.dateDecodingStrategy = .iso8601
    }
    let response = try decoder.decode(DataResponse.self, from: data)
    if let keyPath {
      return try response.decode(T.self, forKey: keyPath)
    }
    return try response.decode(T.self)
  }

  private func request<T: Collection & Decodable>(_ api: API, page: Int, perPage: Int, to type: Page<T>.Type = Page<T>.self, at keyPath: String? = nil) async throws -> Page<T> where T.Element: Decodable {
    let items = try await request(api, to: T.self, at: keyPath)
    return Page(page: page, isAtEnd: items.count < perPage, items: items)
  }
}

// MARK: - Unsplash.ResponseData

extension Unsplash {
  struct DataResponse: Decodable {
    private let decoder: Decoder

    init(from decoder: Decoder) throws {
      self.decoder = decoder
    }

    func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
      try T(from: decoder)
    }

    func decode<T: Decodable>(_ type: T.Type = T.self, forKey key: String) throws -> T {
      let container = try decoder.container(keyedBy: StringCodingKey.self)
      let paths = key.split(separator: ".").compactMap { StringCodingKey($0) }
      guard let finalKey = paths.last else {
        fatalError("keyPath is empty.")
      }
      return try paths.dropLast(1)
        .reduce(container) { try $0.nestedContainer(keyedBy: StringCodingKey.self, forKey: $1) }
        .decode(type, forKey: finalKey)
    }
  }
}
