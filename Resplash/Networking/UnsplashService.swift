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

  @inlinable func featured() -> Single<[Featured]> {
    request(.featured)
  }

  @inlinable func photos(page: Int) -> Single<[ImageAsset]> {
    images(for: .photo, page: page)
  }

  @inlinable func illustrations(page: Int) -> Single<[ImageAsset]> {
    images(for: .illustration, page: page)
  }

  @inlinable func images(for mediaType: MediaType, page: Int) -> Single<[ImageAsset]> {
    switch mediaType {
    case .photo:
      request(.photos(page))
    case .illustration:
      request(.illustrations(page))
    }
  }

  @inlinable func images(for topic: Topic, page: Int) -> Single<[ImageAsset]> {
    request(.topicImages(topic, page))
  }

  @inlinable func images(for collection: ImageAssetCollection, page: Int) -> Single<[ImageAsset]> {
    request(.collectionImages(collection, page))
  }

  @inlinable func collections(for mediaType: MediaType, page: Int) -> Single<[ImageAssetCollection]> {
    request(.collections(mediaType, page))
  }

  @inlinable func imageDetail(for imageAsset: ImageAsset) -> Single<ImageAssetDetail> {
    request(.imageDetail(imageAsset))
  }

  @inlinable func autocomplete(_ query: String, completion: @escaping (Result<[Autocomplete], Error>) -> Void) -> Single<[Autocomplete]> {
    request(.autocomplete(query), keyPath: "autocomplete")
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
          observer(.success(try result.get().map(T.self, using: decoder)))
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
