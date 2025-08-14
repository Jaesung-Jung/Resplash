//
//  MainFeature.swift
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

import Algorithms
import ComposableArchitecture

@Reducer
struct MainFeature {
  @ObservableState
  struct State: Equatable {
    var topics: [Topic]?
    var collections: [ImageAssetCollection]?
    var images: [ImageAsset]?

    var mediaType: MediaType = .photo
    var page: Int = 1
    var hasNextPage: Bool = false
    var isLoading: Bool = false
    var isRefreshing: Bool = false
  }

  enum Action: Sendable {
    case selectMediaType(MediaType)
    case refresh
    case fetch
    case fetchResponse([Topic], [ImageAssetCollection], Page<[ImageAsset]>)
    case fetchNextImages
    case fetchNextImagesResponse(Page<[ImageAsset]>)
  }

  @Dependency(\.unsplash) var unsplash

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .selectMediaType(let mediaType):
        state.mediaType = mediaType
        state.isLoading = true
        return fetch(mediaType: mediaType)

      case .refresh:
        state.isRefreshing = true
        return fetch(mediaType: state.mediaType)

      case .fetch:
        state.isLoading = true
        return fetch(mediaType: state.mediaType)

      case .fetchResponse(let topics, let collections, let images):
        state.topics = topics
        state.collections = collections
        state.images = Array(images.uniqued(on: \.id))
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        state.isLoading = false
        state.isRefreshing = false
        return .none

      case .fetchNextImages:
        guard state.hasNextPage else {
          return .none
        }
        state.isLoading = true
        return .run { [mediaType = state.mediaType, page = state.page] send in
          let images = try await unsplash.images(for: mediaType, page: page + 1)
          await send(.fetchNextImagesResponse(images))
        }

      case .fetchNextImagesResponse(let images):
        state.images = state.images.map { $0 + images }.map { Array($0.uniqued(on: \.id)) }
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        state.isLoading = false
        state.isRefreshing = false
        return .none
      }
    }
  }

  func fetch(mediaType: MediaType) -> Effect<Action> {
    return .run { send in
      async let fetchTopics = unsplash.topics(for: mediaType)
      async let fetchCollections = unsplash.collections(for: mediaType, page: 1)
      async let fetchImages = unsplash.images(for: mediaType, page: 1)
      let (topics, collections, images) = try await (fetchTopics, fetchCollections, fetchImages)
      await send(
        .fetchResponse(topics, collections.items, images)
      )
    }
  }
}
