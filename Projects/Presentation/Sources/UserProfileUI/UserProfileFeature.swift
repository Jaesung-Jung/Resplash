//
//  UserProfileFeature.swift
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

@Reducer
public struct UserProfileFeature {
  @ObservableState
  public struct State: Equatable {
    public let user: Unsplash.User
    public var selectedTab: Tab

    public var photos: Page<Unsplash.Image>?
    public var illustrations: Page<Unsplash.Image>?
    public var collections: Page<Unsplash.ImageCollection>?

    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    public init(user: Unsplash.User) {
      self.user = user
      self.selectedTab = if user.totalPhotos > .zero {
        .photos
      } else if user.totalIllustrations > .zero {
        .illustrations
      } else if user.totalCollections > .zero {
        .collections
      } else {
        .photos
      }
    }
  }

  public enum Action {
    case fetchItems
    case fetchNextItems
    case fetchPhotosResponse(Result<Page<Unsplash.Image>, Error>)
    case fetchNextPhotosResponse(Result<Page<Unsplash.Image>, Error>)
    case fetchIllustrationsResponse(Result<Page<Unsplash.Image>, Error>)
    case fetchNextIllustrationsResponse(Result<Page<Unsplash.Image>, Error>)
    case fetchCollectionsResponse(Result<Page<Unsplash.ImageCollection>, Error>)
    case fetchNextCollectionsResponse(Result<Page<Unsplash.ImageCollection>, Error>)
    case selectTab(Tab)

    case navigate(Navigation)
  }

  public enum Navigation {
    case search(String, Unsplash.MediaType)
    case imageDetail(Unsplash.Image)
    case collectionImages(Unsplash.ImageCollection)
  }

  public enum Tab: Sendable {
    case photos
    case illustrations
    case collections
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .selectTab(let tab):
        state.selectedTab = tab
        switch tab {
        case .photos where state.photos == nil, .illustrations where state.illustrations == nil, .collections where state.collections == nil:
          return .send(.fetchItems)
        default:
          return .none
        }

      case .fetchItems:
        return .run { [unsplash, user = state.user, tab = state.selectedTab] send in
          switch tab {
          case .photos:
            let result = await Result {
              try await unsplash.image.photos(for: user, page: 1)
            }
            await send(.fetchPhotosResponse(result))
          case .illustrations:
            let result = await Result {
              try await unsplash.image.illustrations(for: user, page: 1)
            }
            await send(.fetchIllustrationsResponse(result))
          case .collections:
            let result = await Result {
              try await unsplash.collection.items(for: user, page: 1)
            }
            await send(.fetchCollectionsResponse(result))
          }
        }

      case .fetchNextItems:
        let (hasNextPage, page) = switch state.selectedTab {
        case .photos:
          state.photos.map { (!$0.isAtEnd, $0.page) } ?? (false, 1)
        case .illustrations:
          state.illustrations.map { (!$0.isAtEnd, $0.page) } ?? (false, 1)
        case .collections:
          state.collections.map { (!$0.isAtEnd, $0.page) } ?? (false, 1)
        }
        guard hasNextPage, !state.isLoading else {
          return .none
        }
        state.loading = .loadingMore
        return .run { [unsplash, user = state.user, tab = state.selectedTab] send in
          switch tab {
          case .photos:
            let result = await Result {
              try await unsplash.image.photos(for: user, page: page + 1)
            }
            await send(.fetchNextPhotosResponse(result))
          case .illustrations:
            let result = await Result {
              try await unsplash.image.illustrations(for: user, page: page + 1)
            }
            await send(.fetchNextPhotosResponse(result))
          case .collections:
            let result = await Result {
              try await unsplash.collection.items(for: user, page: page + 1)
            }
            await send(.fetchNextCollectionsResponse(result))
          }
        }

      case .fetchPhotosResponse(.success(let photos)):
        state.loading = .none
        state.photos = photos
        return .none

      case .fetchNextPhotosResponse(.success(let photos)):
        state.loading = .none
        state.photos = state.photos
          .map { $0.items + photos.items }
          .map { Page(page: photos.count, pageSize: photos.count, items: $0.uniqued()) }
        return .none

      case .fetchIllustrationsResponse(.success(let illustrations)):
        state.loading = .none
        state.illustrations = illustrations
        return .none

      case .fetchNextIllustrationsResponse(.success(let illustrations)):
        state.loading = .none
        state.illustrations = state.illustrations
          .map { $0.items + illustrations.items }
          .map { Page(page: illustrations.count, pageSize: illustrations.count, items: $0.uniqued()) }
        return .none

      case .fetchCollectionsResponse(.success(let collections)):
        state.loading = .none
        state.collections = collections
        return .none

      case .fetchNextCollectionsResponse(.success(let collections)):
        state.loading = .none
        state.collections = state.collections
          .map { $0.items + collections.items }
          .map { Page(page: collections.count, pageSize: collections.count, items: $0.uniqued()) }
        return .none

      case .fetchPhotosResponse(.failure(let error)),
          .fetchIllustrationsResponse(.failure(let error)),
          .fetchCollectionsResponse(.failure(let error)),
          .fetchNextPhotosResponse(.failure(let error)),
          .fetchNextIllustrationsResponse(.failure(let error)),
          .fetchNextCollectionsResponse(.failure(let error)):
        return .none

      default:
        return .none
      }
    }
  }
}
