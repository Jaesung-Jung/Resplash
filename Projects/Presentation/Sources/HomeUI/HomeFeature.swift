//
//  HomeFeature.swift
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

@Reducer
public struct HomeFeature {
  public typealias Contents = (topics: [Topic], collections: [AssetCollection], images: Page<Asset>)

  @ObservableState
  public struct State: Equatable {
    var topics: [Topic]?
    var collections: [AssetCollection]?
    var images: [Asset]?

    var mediaType: MediaType = .photo
    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    var page = 1
    var hasNextPage = false

    public init() {}
  }

  public enum Action {
    case fetchContents
    case fetchNextImages
    case fetchContentsResponse(Result<Contents, Error>)
    case fetchNextImagesResponse(Result<Page<Asset>, Error>)
    case selectMediaType(MediaType)

    case selectTopic(Topic)
    case selectCollection(AssetCollection)
    case selectImage(Asset)
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchContents:
        state.loading = .loading
        return .run { [unsplash, mediaType = state.mediaType] send in
          let result = await Result {
            async let topics = unsplash.topic.items(for: mediaType)
            async let collections = unsplash.collection.items(for: mediaType, page: 1)
            async let images = unsplash.asset.images(for: mediaType, page: 1)
            return try await (topics: topics, collections: collections.items, images: images)
          }
          await send(.fetchContentsResponse(result))
        }

      case .fetchNextImages:
        guard state.hasNextPage, !state.isLoading else {
          return .none
        }
        state.loading = .loadingMore
        return .run { [unsplash, mediaType = state.mediaType, page = state.page] send in
          let result = await Result {
            try await unsplash.asset.images(for: mediaType, page: page + 1)
          }
          await send(.fetchNextImagesResponse(result))
        }

      case .fetchContentsResponse(.success(let contents)):
        state.loading = .none
        state.topics = contents.topics
        state.collections = contents.collections
        state.images = Array(contents.images.uniqued())
        state.page = contents.images.page
        state.hasNextPage = !contents.images.isAtEnd
        return .none

      case .fetchNextImagesResponse(.success(let images)):
        state.loading = .none
        state.images = state.images
          .map { $0 + images }
          .map { Array($0.uniqued()) }
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        return .none

      case .fetchContentsResponse(.failure(let error)), .fetchNextImagesResponse(.failure(let error)):
        print(error)
        return .none

      case .selectMediaType(let mediaType):
        guard mediaType != state.mediaType else {
          return .none
        }
        state.mediaType = mediaType
        return .send(.fetchContents)

      case .selectTopic, .selectCollection, .selectImage:
        return .none
      }
    }
  }
}
