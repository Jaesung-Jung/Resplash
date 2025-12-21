//
//  CollectionsFeature.swift
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

import ComposableArchitecture
import ResplashUI
import ResplashClients
import ResplashEntities
import ResplashUtils
import ResplashStrings

@Reducer
public struct CollectionsFeature {
  @ObservableState
  public struct State: Equatable {
    public let mediaType: MediaType
    public var collections: [AssetCollection]?

    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    var page: Int = 1
    var hasNextPage: Bool = false

    public init(mediaType: MediaType) {
      self.mediaType = mediaType
    }
  }

  public enum Action {
    case fetchCollections
    case fetchNextCollections
    case fetchCollectionsResponse(Result<Page<AssetCollection>, Error>)
    case fetchNextCollectionsResponse(Result<Page<AssetCollection>, Error>)

    case navigate(Navigation)
  }

  public enum Navigation {
    case collectionImages(AssetCollection)
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchCollections:
        state.loading = .loading
        return .run { [unsplash, mediaType = state.mediaType] send in
          let result = await Result { try await unsplash.collection.items(for: mediaType, page: 1) }
          await send(.fetchCollectionsResponse(result))
        }

      case .fetchNextCollections:
        guard state.hasNextPage, !state.isLoading else {
          return .none
        }
        state.loading = .loading
        return .run { [unsplash, mediaType = state.mediaType, page = state.page] send in
          let result = await Result { try await unsplash.collection.items(for: mediaType, page: page + 1) }
          await send(.fetchNextCollectionsResponse(result))
        }

      case .fetchCollectionsResponse(.success(let collections)):
        state.loading = .none
        state.collections = Array(collections.uniqued())
        state.page = collections.page
        state.hasNextPage = !collections.isAtEnd
        return .none

      case .fetchNextCollectionsResponse(.success(let collections)):
        state.loading = .none
        state.collections = state.collections.map { $0 + collections }.map { Array($0.uniqued()) }
        state.page = collections.page
        state.hasNextPage = !collections.isAtEnd
        return .none

      case .fetchCollectionsResponse(.failure(let error)), .fetchNextCollectionsResponse(.failure(let error)):
        state.loading = .none
        return .none

      case .navigate:
        return .none
      }
    }
  }
}
