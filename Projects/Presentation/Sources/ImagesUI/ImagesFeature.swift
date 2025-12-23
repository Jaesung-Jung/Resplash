//
//  ImagesFeature.swift
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

import Foundation
import ComposableArchitecture
import ResplashUI
import ResplashClients
import ResplashEntities
import ResplashUtils
import ResplashStrings

@Reducer
public struct ImagesFeature {
  public typealias Category = Unsplash.Category

  @ObservableState
  public struct State: Equatable {
    public let item: Item
    public var shareLink: URL? { item.shareLink }
    public var images: [Unsplash.Image]?

    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    var page: Int = 1
    var hasNextPage: Bool = false

    public init(item: Item) {
      self.item = item
    }
  }

  public enum Action {
    case fetchImages
    case fetchNextImages
    case fetchImagesResponse(Result<Page<Unsplash.Image>, Error>)
    case fetchNextImagesResponse(Result<Page<Unsplash.Image>, Error>)

    case navigate(Navigation)
  }

  public enum Navigation {
    case imageDetail(Unsplash.Image)
  }

  public enum Item: Equatable, Sendable {
    case topic(Unsplash.Topic)
    case category(Unsplash.Category.Item)
    case collection(Unsplash.ImageCollection)

    var shareLink: URL? {
      switch self {
      case .topic(let topic):
        topic.shareLink
      case .category:
        nil
      case .collection(let collection):
        collection.shareLink
      }
    }
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchImages:
        state.loading = .loading
        return .run { [unsplash, item = state.item] send in
          let result = await Result { try await unsplash.images(for: item, page: 1) }
          await send(.fetchImagesResponse(result))
        }

      case .fetchNextImages:
        guard state.hasNextPage, !state.isLoading else {
          return .none
        }
        state.loading = .loadingMore
        return .run { [unsplash, item = state.item, page = state.page] send in
          let result = await Result { try await unsplash.images(for: item, page: page + 1) }
          await send(.fetchNextImagesResponse(result))
        }

      case .fetchImagesResponse(.success(let images)):
        state.loading = .none
        state.images = Array(images.uniqued())
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        return .none

      case .fetchNextImagesResponse(.success(let images)):
        state.loading = .none
        state.images = state.images.map { $0 + images }.map { Array($0.uniqued()) }
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        return .none

      case .fetchImagesResponse(.failure(let error)), .fetchNextImagesResponse(.failure(let error)):
        state.loading = .none
        print(error)
        return .none

      case .navigate:
        return .none
      }
    }
  }
}

// MARK: - UnsplashClient

extension UnsplashClient {
  func images(for item: ImagesFeature.Item, page: Int) async throws -> Page<Unsplash.Image> {
    switch item {
    case .topic(let topic):
      try await self.topic.images(for: topic, page: page)
    case .category(let category):
      try await self.category.images(for: category, page: page)
    case .collection(let collection):
      try await self.collection.images(for: collection, page: page)
    }
  }
}
