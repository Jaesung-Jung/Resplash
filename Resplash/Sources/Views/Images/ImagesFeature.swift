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

import OSLog
import Algorithms
import ComposableArchitecture

@Reducer
struct ImagesFeature {
  @ObservableState
  struct State: Equatable {
    let item: Item
    var title: String { item.title }
    var subtitle: LocalizedStringResource { item.subtitle }
    var shareLink: URL? { item.shareLink }
    var images: [ImageAsset]?
    var activityState: ActivityState = .idle

    var page: Int = 1
    var hasNextPage: Bool = false
  }

  enum Action {
    case fetch
    case fetchNext
    case fetchResponse(Result<Page<[ImageAsset]>, Error>)
    case fetchNextResponse(Result<Page<[ImageAsset]>, Error>)
  }

  enum Item: Equatable {
    case topic(Topic)
    case category(Category.Item)
    case collection(ImageAssetCollection)

    var title: String {
      switch self {
      case .topic(let topic):
        topic.title
      case .category(let category):
        category.title
      case .collection(let collection):
        collection.title
      }
    }

    var subtitle: LocalizedStringResource {
      switch self {
      case .topic(let topic):
        topic.owners.first.map { "Created by \($0.name)" } ?? ""
      default:
        ""
      }
    }

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
  @Dependency(\.logger) var logger

  func images(for item: Item, page: Int) async throws -> Page<[ImageAsset]> {
    switch item {
    case .topic(let topic):
      try await unsplash.images(for: topic, page: page)
    case .category(let category):
      try await unsplash.images(for: category, page: page)
    case .collection(let collection):
      try await unsplash.images(for: collection, page: page)
    }
  }

  var body: some ReducerOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
      case .fetch:
        state.activityState = .reloading
        return .run { [item = state.item] send in
          do {
            let images = try await images(for: item, page: 1)
            await send(.fetchResponse(.success(images)))
          } catch {
            await send(.fetchResponse(.failure(error)))
          }
        }

      case .fetchNext:
        guard state.hasNextPage, !state.activityState.isActive else {
          return .none
        }
        state.activityState = .loading
        return .run { [item = state.item, page = state.page] send in
          do {
            let images = try await images(for: item, page: page + 1)
            await send(.fetchNextResponse(.success(images)))
          } catch {
            await send(.fetchNextResponse(.failure(error)))
          }
        }

      case .fetchResponse(.success(let images)):
        state.images = Array(images.uniqued(on: \.id))
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        state.activityState = .idle
        return .none

      case .fetchNextResponse(.success(let images)):
        state.images = state.images.map { $0 + images }.map { Array($0.uniqued(on: \.id)) }
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
        state.activityState = .idle
        return .none

      case .fetchResponse(.failure(let error)):
        logger.fault("\(error)")
        state.activityState = .idle
        return .none

      case .fetchNextResponse(.failure(let error)):
        logger.fault("\(error)")
        state.activityState = .idle
        return .none
      }
    }
  }
}
