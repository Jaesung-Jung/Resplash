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

import OSLog
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
    var activityState: ActivityState = .idle

    var page: Int = 1
    var hasNextPage: Bool = false
  }

  enum Action: Sendable {
    case selectMediaType(MediaType)

    case fetch
    case fetchNextImages
    case fetchResponse(Result<(topics: [Topic], collections: [ImageAssetCollection], images: Page<[ImageAsset]>), Error>)
    case fetchNextImagesResponse(Result<Page<[ImageAsset]>, Error>)

    case navigateToCollections(MediaType)
    case navigateToImages(ImagesFeature.Item)
    case navigateToImageDetail(ImageAsset)
  }

  @Dependency(\.unsplash) var unsplash
  @Dependency(\.logger) var logger

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .selectMediaType(let mediaType):
        state.mediaType = mediaType
        state.activityState = .reloading
        return fetch(mediaType: mediaType)

      case .fetch:
        state.activityState = .reloading
        return fetch(mediaType: state.mediaType)

      case .fetchNextImages:
        guard state.hasNextPage, !state.activityState.isActive else {
          return .none
        }
        state.activityState = .loading
        return .run { [mediaType = state.mediaType, page = state.page] send in
          do {
            let images = try await unsplash.images(for: mediaType, page: page + 1)
            await send(.fetchNextImagesResponse(.success(images)))
          } catch {
            await send(.fetchNextImagesResponse(.failure(error)))
          }
        }

      case .fetchResponse(.success(let result)):
        state.topics = result.topics
        state.collections = result.collections
        state.images = Array(result.images.uniqued(on: \.id))
        state.page = result.images.page
        state.hasNextPage = !result.images.isAtEnd
        state.activityState = .idle
        return .none

      case .fetchNextImagesResponse(.success(let images)):
        state.images = state.images.map { $0 + images }.map { Array($0.uniqued(on: \.id)) }
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        state.activityState = .idle
        return .none

      case .fetchResponse(.failure(let error)), .fetchNextImagesResponse(.failure(let error)):
        logger.fault("\(error)")
        state.activityState = .idle
        return .none

      case .navigateToCollections, .navigateToImages, .navigateToImageDetail:
        return .none
      }
    }
  }

  private func fetch(mediaType: MediaType) -> Effect<Action> {
    return .run { send in
      async let fetchTopics = unsplash.topics(for: mediaType)
      async let fetchCollections = unsplash.collections(for: mediaType, page: 1)
      async let fetchImages = unsplash.images(for: mediaType, page: 1)
      do {
        let (topics, collections, images) = try await (fetchTopics, fetchCollections, fetchImages)
        await send(.fetchResponse(.success((topics, collections.items, images))))
      } catch {
        await send(.fetchResponse(.failure(error)))
      }
    }
  }
}
