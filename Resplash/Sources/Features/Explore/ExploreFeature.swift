//
//  ExploreFeature.swift
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
struct ExploreFeature {
  @ObservableState
  struct State: Equatable {
    var categories: [Category]?
    var images: [ImageAsset]?
    var loadingPhase: LoadingPhase = .idle

    var page: Int = 1
    var hasNextPage: Bool = false
  }

  enum Action {
    case fetch
    case fetchNext
    case fetchResponse(Result<([Category], Page<[ImageAsset]>), Error>)
    case fetchNextResponse(Result<Page<[ImageAsset]>, Error>)

    case navigateToImages(ImagesFeature.Item)
    case navigateToImageDetail(ImageAsset)
  }

  @Dependency(\.unsplash) var unsplash
  @Dependency(\.logger) var logger

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetch:
        state.loadingPhase = .initial
        return .run { send in
          let result = await Result {
            async let fetchCategories = unsplash.categories()
            async let fetchImages = unsplash.images(for: .photo, page: 1)
            return try await (fetchCategories, fetchImages)
          }
          await send(.fetchResponse(result))
        }

      case .fetchNext:
        guard state.hasNextPage, !state.loadingPhase.isLoading else {
          return .none
        }
        state.loadingPhase = .loading
        return .run { [page = state.page] send in
          let result = await Result { try await unsplash.images(for: .photo, page: page + 1) }
          await send(.fetchNextResponse(result))
        }

      case .fetchResponse(.success((let categories, let images))):
        state.categories = categories
        state.images = Array(images.uniqued(on: \.id))
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        state.loadingPhase = .idle
        return .none

      case .fetchNextResponse(.success(let images)):
        state.images = state.images.map { $0 + images }.map { Array($0.uniqued(on: \.id)) }
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        state.loadingPhase = .idle
        return .none

      case .fetchResponse(.failure(let error)), .fetchNextResponse(.failure(let error)):
        logger.fault("\(error)")
        state.loadingPhase = .idle
        return .none

      case .navigateToImages, .navigateToImageDetail:
        return .none
      }
    }
  }
}
