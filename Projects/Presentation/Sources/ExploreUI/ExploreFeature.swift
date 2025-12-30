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

import ComposableArchitecture
import ResplashUI
import ResplashClients
import ResplashEntities
import ResplashUtils

@Reducer
public struct ExploreFeature {
  @ObservableState
  public struct State: Equatable {
    var categories: [Unsplash.Category]?
    var images: [Unsplash.Image]?

    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    var page = 1
    var hasNextPage = false

    public init() {
    }
  }

  public enum Action {
    case fetch
    case fetchNext
    case fetchResponse(Result<([Unsplash.Category], Page<Unsplash.Image>), Error>)
    case fetchNextResponse(Result<Page<Unsplash.Image>, Error>)

    case navigate(Navigation)
  }

  public enum Navigation {
    case images(Unsplash.Category.Item)
    case imageDetail(Unsplash.Image)
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetch:
        state.loading = .loading
        return .run { [unsplash] send in
          let result = await Result {
            async let fetchCategories = unsplash.category.items()
            async let fetchImages = unsplash.image.images(for: .photo, page: 1)
            return try await (fetchCategories, fetchImages)
          }
          await send(.fetchResponse(result))
        }

      case .fetchNext:
        guard state.hasNextPage, !state.isLoading else {
          return .none
        }
        state.loading = .loadingMore
        return .run { [unsplash, page = state.page] send in
          let result = await Result { try await unsplash.image.images(for: .photo, page: page + 1) }
          await send(.fetchNextResponse(result))
        }

      case .fetchResponse(.success((let categories, let images))):
        state.loading = .none
        state.categories = categories
        state.images = Array(images.uniqued())
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        return .none

      case .fetchNextResponse(.success(let images)):
        state.loading = .none
        state.images = state.images.map { $0 + images }.map { Array($0.uniqued(on: \.id)) }
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        return .none

      case .fetchResponse(.failure(let error)), .fetchNextResponse(.failure(let error)):
        state.loading = .none
        return .none

      case .navigate:
        return .none
      }
    }
  }
}
