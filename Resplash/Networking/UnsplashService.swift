//
//  UnsplashService.swift
//  Resplash
//
//  Created by 정재성 on 7/3/25.
//

import Foundation
import Moya
import RxSwift

struct UnsplashService {
  private let provider: MoyaProvider<UnsplashAPI>

  init(strategy: Strategy = .live) {
    #if DEBUG
    if ProcessInfo.processInfo.isPreview {
      self.provider = MoyaProvider(stubClosure: { _ in .immediate })
    } else {
      switch strategy {
      case .live:
        self.provider = MoyaProvider()
      case .stub(let delay):
        self.provider = MoyaProvider(stubClosure: { _ in
          delay.map { .delayed(seconds: $0) } ?? .immediate
        })
      }
    }
    #else
    self.provider = MoyaProvider()
    #endif
  }

  @inlinable func topics(for mediaType: MediaType) -> Single<[Topic]> {
    request(.topics, to: [Topic].self).map {
      $0.filter { $0.mediaTypes.contains(mediaType) }
    }
  }

  @inlinable func categories() -> Single<[Category]> {
    request(.categories)
  }

  @inlinable func photos(page: Int) -> Single<Page<[ImageAsset]>> {
    images(for: .photo, page: page)
  }

  @inlinable func illustrations(page: Int) -> Single<Page<[ImageAsset]>> {
    images(for: .illustration, page: page)
  }

  @inlinable func images(for mediaType: MediaType, page: Int) -> Single<Page<[ImageAsset]>> {
    let perPage = 30
    switch mediaType {
    case .photo:
      return request(.photos(page: page, perPage: perPage))
        .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
    case .illustration:
      return request(.illustrations(page: page, perPage: perPage))
        .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
    }
  }

  @inlinable func images(for topic: Topic, page: Int) -> Single<Page<[ImageAsset]>> {
    let perPage = 30
    return request(.topicImages(topic: topic, page: page, perPage: perPage))
      .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
  }

  @inlinable func images(for collection: ImageAssetCollection, page: Int) -> Single<Page<[ImageAsset]>> {
    let perPage = 30
    return request(.collectionImages(collection: collection, page: page, perPage: perPage))
      .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
  }

  @inlinable func images(for category: Category.Item, page: Int) -> Single<Page<[ImageAsset]>> {
    let perPage = 30
    return request(.categoryImages(category: category, page: page, perPage: perPage), keyPath: "photos")
      .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
  }

  @inlinable func collections(for mediaType: MediaType, page: Int) -> Single<Page<[ImageAssetCollection]>> {
    let perPage = 30
    return request(.collections(mediaType: mediaType, page: page, perPage: perPage))
      .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
  }

  @inlinable func imageDetail(for image: ImageAsset) -> Single<ImageAssetDetail> {
    request(.imageDetail(image: image))
  }

  @inlinable func seriesImages(for image: ImageAsset) -> Single<[ImageAsset]> {
    request(.seriesImages(image: image))
  }

  @inlinable func relatedImage(for image: ImageAsset, page: Int) -> Single<Page<[ImageAsset]>> {
    let perPage = 20
    return request(.relatedImages(image: image, page: page, perPage: perPage), keyPath: "results")
      .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
  }

  @inlinable func searchSuggestion(_ query: String) -> Single<SearchSuggestion> {
    request(.autocomplete(query: query))
  }

  @inlinable func searchPhotos(_ query: String, page: Int) -> Single<Page<[ImageAsset]>> {
    let perPage = 20
    return request(.searchPhotos(query: query, page: page, perPage: perPage), keyPath: "results")
      .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
  }

  @inlinable func searchIllustrations(_ query: String, page: Int) -> Single<Page<[ImageAsset]>> {
    let perPage = 20
    return request(.searchIllustrations(query: query, page: page, perPage: perPage), keyPath: "results")
      .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
  }

  @inlinable func searchCollections(_ query: String, page: Int) -> Single<Page<[ImageAssetCollection]>> {
    let perPage = 20
    return request(.searchCollections(query: query, page: page, perPage: perPage), keyPath: "results")
      .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
  }

  @inlinable func searchUsers(_ query: String, page: Int) -> Single<Page<[User]>> {
    let perPage = 20
    return request(.searchUsers(query: query, page: page, perPage: perPage), keyPath: "results")
      .map { Page(page: page, isAtEnd: $0.count < perPage, items: $0) }
  }

  @inlinable func searchTrends() -> Single<[Trend]> {
    // 2페이지 부터 응답속도 문제로 인해 1페이지만 요청
    request(.searchTrends(page: 1, perPage: 20))
  }

  @inlinable func searchMeta(_ query: String) -> Single<SearchMeta> {
    request(.searchMeta(query: query))
  }
}

// MARK: - UnsplashService.Strategy

extension UnsplashService {
  enum Strategy {
    case live
    case stub(delay: TimeInterval?)
  }
}

// MARK: - UnsplashService (Private)

extension UnsplashService {
  private func request<T: Decodable>(_ target: UnsplashAPI, to type: T.Type = T.self, keyPath: String? = nil) -> Single<T> {
    Single.create { [provider] observer in
      provider.request(target) { result in
        do {
          let decoder = JSONDecoder().then {
            $0.dateDecodingStrategy = .iso8601
          }
          observer(.success(try result.get().map(T.self, atKeyPath: keyPath, using: decoder)))
        } catch {
          observer(.failure(error))
        }
      }
      return Disposables.create()
    }
  }
}

// MARK: - Dependencies (UnsplashService)

#if canImport(Dependencies)

import Dependencies

extension UnsplashService: DependencyKey {
  static var liveValue: UnsplashService { UnsplashService() }
  static var previewValue: UnsplashService { UnsplashService(strategy: .stub(delay: nil)) }
}

extension DependencyValues {
  var unsplashService: UnsplashService {
    get { self[UnsplashService.self] }
    set { self[UnsplashService.self] = newValue }
  }
}

#endif
