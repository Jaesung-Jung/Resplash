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

  @inlinable func topics() -> Single<[Topic]> {
    request(.topics)
  }

  @inlinable func featured() -> Single<[Featured]> {
    request(.featured)
  }

  @inlinable func photos(page: Int) -> Single<Page<[ImageAsset]>> {
    request(.photos(page)).map { Page(number: page, items: $0) }
  }

  @inlinable func illustrations(page: Int) -> Single<Page<[ImageAsset]>> {
    request(.illustrations(page)).map { Page(number: page, items: $0) }
  }

  @inlinable func collections(for mediaType: MediaType, page: Int) -> Single<Page<[ImageAssetCollection]>> {
    request(.collections(mediaType, page)).map { Page(number: page, items: $0) }
  }

  @inlinable func autocomplete(_ query: String) -> Single<[Autocomplete]> {
    request(.autocomplete(query), at: "autocomplete")
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
  private func request<T: Decodable>(_ target: UnsplashAPI, at keyPath: String? = nil) -> Single<T> {
    Single.create { [provider] observer in
      provider.request(target) { result in
        do {
          let response = try result.get()
          let decodedData = try response.map(T.self, atKeyPath: keyPath, using: JSONDecoder().then {
            $0.dateDecodingStrategy = .iso8601
          })
          observer(.success(decodedData))
        } catch {
          observer(.failure(error))
        }
      }
      return Disposables.create()
    }
  }
}
