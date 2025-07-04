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

  init() {
    self.provider = MoyaProvider()
  }

  @inlinable func photos(page: Int) -> Single<[ImageAsset]> {
    request(.photos(page))
  }

  @inlinable func illustrations(page: Int) -> Single<[ImageAsset]> {
    request(.illustrations(page))
  }

  @inlinable func autocomplete(_ query: String) -> Single<[Autocomplete]> {
    request(.autocomplete(query), at: "autocomplete")
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
