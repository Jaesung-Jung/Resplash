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
        self.provider = MoyaProvider(plugins: [NetworkLoggerPlugin()])
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

  @inlinable func topics(completion: @escaping (Result<[Topic], Error>) -> Void) {
    request(.topics, completion: completion)
  }

  @inlinable func featured(completion: @escaping (Result<[Featured], Error>) -> Void) {
    request(.featured, completion: completion)
  }

  @inlinable func photos(page: Int, completion: @escaping (Result<[ImageAsset], Error>) -> Void) {
    images(for: .photo, page: page, completion: completion)
  }

  @inlinable func illustrations(page: Int, completion: @escaping (Result<[ImageAsset], Error>) -> Void) {
    images(for: .illustration, page: page, completion: completion)
  }

  @inlinable func images(for mediaType: MediaType, page: Int, completion: @escaping (Result<[ImageAsset], Error>) -> Void) {
    switch mediaType {
    case .photo:
      request(.photos(page), completion: completion)
    case .illustration:
      request(.illustrations(page), completion: completion)
    }
  }

  @inlinable func collections(for mediaType: MediaType, page: Int, completion: @escaping (Result<[ImageAssetCollection], Error>) -> Void) {
    request(.collections(mediaType, page), completion: completion)
  }

  @inlinable func autocomplete(_ query: String, completion: @escaping (Result<[Autocomplete], Error>) -> Void) {
    request(.autocomplete(query), at: "autocomplete", completion: completion)
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
  private func request<T: Decodable>(_ target: UnsplashAPI, at keyPath: String? = nil, completion: @escaping (Result<T, Error>) -> Void) {
    provider.request(target) { result in
      do {
        let response = try result.get()
        let decodedData = try response.map(T.self, atKeyPath: keyPath, using: JSONDecoder().then {
          $0.dateDecodingStrategy = .iso8601
        })
        completion(.success(decodedData))
      } catch {
        completion(.failure(error))
      }
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
