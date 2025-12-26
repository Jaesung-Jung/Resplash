//
//  SearchResultFeature.swift
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
public struct SearchResultFeature {
  @ObservableState
  public struct State: Equatable {
    let query: String
    var mediaType: Unsplash.MediaType

    var searchMeta: Unsplash.SearchMeta?
    var users: [Unsplash.User]?
    var collections: [Unsplash.ImageCollection]?
    var images: [Unsplash.Image]?

    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    var page = 1
    var hasNextPage = false

    public init(query: String, mediaType: Unsplash.MediaType) {
      self.query = query
      self.mediaType = mediaType
    }
  }

  public enum Action {
    case fetchContents
    case fetchNextImages
    case fetchContentsResponse(Result<(Unsplash.SearchMeta, [Unsplash.User], [Unsplash.ImageCollection], Page<Unsplash.Image>), Error>)
    case fetchNextImagesResponse(Result<Page<Unsplash.Image>, Error>)
    case selectMediaType(Unsplash.MediaType)

    case navigate(Navigation)
  }

  public enum Navigation {
    case search(String, Unsplash.MediaType)
    case users(String)
    case userProfile(Unsplash.User)
    case collections(String)
    case collectionImages(Unsplash.ImageCollection)
    case imageDetail(Unsplash.Image)
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchContents:
        state.loading = .loading
        return .run { [unsplash, query = state.query, mediaType = state.mediaType] send in
          let result = await Result {
            async let meta = unsplash.search.meta(query: query)
            async let users = unsplash.search.users(query: query, page: 1)
            async let collections = unsplash.search.collections(query: query, page: 1)
            async let images = unsplash.search.images(for: mediaType, query: query, page: 1)
            return try await (meta, users.items, collections.items, images)
          }
          await send(.fetchContentsResponse(result))
        }

      case .fetchNextImages:
        guard state.hasNextPage, !state.isLoading else {
          return .none
        }
        state.loading = .loadingMore
        return .run { [unsplash, query = state.query, mediaType = state.mediaType, page = state.page] send in
          let result = await Result {
            try await unsplash.search.images(for: mediaType, query: query, page: page + 1)
          }
          await send(.fetchNextImagesResponse(result))
        }

      case .fetchContentsResponse(.success((let meta, let users, let collections, let images))):
        state.loading = .none
        state.searchMeta = meta
        state.users = users
        state.collections = collections
        state.images = Array(images.uniqued())
        state.page = images.page
        state.hasNextPage = !images.isAtEnd
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
        return .none

      case .selectMediaType(let mediaType):
        guard mediaType != state.mediaType else {
          return .none
        }
        state.mediaType = mediaType
        return .send(.fetchContents)

      case .navigate:
        return .none
      }
    }
  }
}
