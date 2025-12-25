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
    var searchType: SearchType
    var searchMeta: Unsplash.SearchMeta?

    var photos: Page<Unsplash.Image>?
    var illustrations: Page<Unsplash.Image>?
    var collections: Page<Unsplash.ImageCollection>?
    var users: Page<Unsplash.User>?

    var page: Int {
      switch searchType {
      case .photo:
        photos?.page ?? 1
      case .illustration:
        illustrations?.page ?? 1
      case .collection:
        collections?.page ?? 1
      case .user:
        users?.page ?? 1
      }
    }

    var hasNextPage: Bool {
      switch searchType {
      case .photo:
        photos.map { !$0.isAtEnd } ?? false
      case .illustration:
        illustrations.map { !$0.isAtEnd } ?? false
      case .collection:
        collections.map { !$0.isAtEnd } ?? false
      case .user:
        users.map { !$0.isAtEnd } ?? false
      }
    }

    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    public init(query: String, mediaType: Unsplash.MediaType) {
      self.query = query
      switch mediaType {
      case .photo:
        searchType = .photo
      case .illustration:
        searchType = .illustration
      }
    }
  }

  public enum Action {
    case fetchItems
    case fetchNextItems
    case selectSearchType(SearchType)

    case fetchPhotoResponse(Result<(Page<Unsplash.Image>, Unsplash.SearchMeta), Error>)
    case fetchNextPhotoResponse(Result<Page<Unsplash.Image>, Error>)

    case fetchIllustrationResponse(Result<(Page<Unsplash.Image>, Unsplash.SearchMeta), Error>)
    case fetchNextIllustrationResponse(Result<Page<Unsplash.Image>, Error>)

    case fetchCollectionResponse(Result<(Page<Unsplash.ImageCollection>, Unsplash.SearchMeta), Error>)
    case fetchNextCollectionResponse(Result<Page<Unsplash.ImageCollection>, Error>)

    case fetchUserResponse(Result<(Page<Unsplash.User>, Unsplash.SearchMeta), Error>)
    case fetchNextUserResponse(Result<Page<Unsplash.User>, Error>)

    case navigate(Navigation)
  }

  public enum Navigation {
    case search(String)
  }

  public enum SearchType: CaseIterable, Sendable {
    case photo
    case illustration
    case collection
    case user
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchItems:
        state.loading = .loading
        return .run { [unsplash, query = state.query, type = state.searchType, meta = state.searchMeta] send in
          switch type {
          case .photo:
            let result = await Result {
              async let fetchItems = unsplash.search.photos(query: query, page: 1)
              if let meta {
                return try await (fetchItems, meta)
              }
              return try await (fetchItems, unsplash.search.meta(query: query))
            }
            await send(.fetchPhotoResponse(result))
          case .illustration:
            let result = await Result {
              async let fetchItems = unsplash.search.illustrations(query: query, page: 1)
              if let meta {
                return try await (fetchItems, meta)
              }
              return try await (fetchItems, unsplash.search.meta(query: query))
            }
            await send(.fetchIllustrationResponse(result))
          case .collection:
            let result = await Result {
              async let fetchItems = unsplash.search.collections(query: query, page: 1)
              if let meta {
                return try await (fetchItems, meta)
              }
              return try await (fetchItems, unsplash.search.meta(query: query))
            }
            await send(.fetchCollectionResponse(result))
          case .user:
            let result = await Result {
              async let fetchItems = unsplash.search.users(query: query, page: 1)
              if let meta {
                return try await (fetchItems, meta)
              }
              return try await (fetchItems, unsplash.search.meta(query: query))
            }
            await send(.fetchUserResponse(result))
          }
        }

      case .fetchNextItems:
        guard !state.isLoading, state.hasNextPage else {
          return .none
        }
        state.loading = .loadingMore
        return .run { [unsplash, query = state.query, type = state.searchType, page = state.page] send in
          switch type {
          case .photo:
            let result = await Result { try await unsplash.search.photos(query: query, page: page + 1) }
            await send(.fetchNextPhotoResponse(result))
          case .illustration:
            let result = await Result { try await unsplash.search.illustrations(query: query, page: page + 1) }
            await send(.fetchNextIllustrationResponse(result))
          case .collection:
            let result = await Result { try await unsplash.search.collections(query: query, page: page + 1) }
            await send(.fetchNextCollectionResponse(result))
          case .user:
            let result = await Result { try await unsplash.search.users(query: query, page: page + 1) }
            await send(.fetchNextUserResponse(result))
          }
        }

      case .selectSearchType(let searchType):
        guard state.searchType != searchType else {
          return .none
        }
        state.searchType = searchType
        switch searchType {
        case .photo where state.photos == nil:
          return .send(.fetchItems)
        case .illustration where state.illustrations == nil:
          return .send(.fetchItems)
        case .collection where state.collections == nil:
          return .send(.fetchItems)
        case .user where state.users == nil:
          return .send(.fetchItems)
        default:
          return .none
        }

      case .fetchPhotoResponse(.success((let page, let meta))):
        state.loading = .none
        state.searchMeta = meta
        setPage(page, in: &state, keyPath: \.photos)
        return .none

      case .fetchIllustrationResponse(.success((let page, let meta))):
        state.loading = .none
        state.searchMeta = meta
        setPage(page, in: &state, keyPath: \.illustrations)
        return .none

      case .fetchCollectionResponse(.success((let page, let meta))):
        state.loading = .none
        state.searchMeta = meta
        setPage(page, in: &state, keyPath: \.collections)
        return .none

      case .fetchUserResponse(.success((let page, let meta))):
        state.loading = .none
        state.searchMeta = meta
        setPage(page, in: &state, keyPath: \.users)
        return .none

      case .fetchNextPhotoResponse(.success(let page)):
        state.loading = .none
        appendPage(page, in: &state, keyPath: \.photos)
        return .none

      case .fetchNextIllustrationResponse(.success(let page)):
        state.loading = .none
        appendPage(page, in: &state, keyPath: \.illustrations)
        return .none

      case .fetchNextCollectionResponse(.success(let page)):
        state.loading = .none
        appendPage(page, in: &state, keyPath: \.collections)
        return .none

      case .fetchNextUserResponse(.success(let page)):
        state.loading = .none
        appendPage(page, in: &state, keyPath: \.users)
        return .none

      case .fetchPhotoResponse(.failure(let error)), .fetchNextPhotoResponse(.failure(let error)):
        print(error)
        state.loading = .none
        return .none

      case .fetchIllustrationResponse(.failure(let error)), .fetchNextIllustrationResponse(.failure(let error)):
        state.loading = .none
        return .none

      case .fetchCollectionResponse(.failure(let error)), .fetchNextCollectionResponse(.failure(let error)):
        state.loading = .none
        return .none

      case .fetchUserResponse(.failure(let error)), .fetchNextUserResponse(.failure(let error)):
        state.loading = .none
        return .none

      case .navigate:
        return .none
      }
    }
  }

  func setPage<Item: Hashable>(_ page: Page<Item>, in state: inout State, keyPath: WritableKeyPath<State, Page<Item>?>) {
    state[keyPath: keyPath] = Page(page: page.page, isAtEnd: page.isAtEnd, items: page.items.uniqued())
  }

  func appendPage<Item: Hashable>(_ page: Page<Item>, in state: inout State, keyPath: WritableKeyPath<State, Page<Item>?>) {
    guard let items = state[keyPath: keyPath]?.items else {
      state[keyPath: keyPath] = Page(page: page.page, isAtEnd: page.isAtEnd, items: page.items.uniqued())
      return
    }
    state[keyPath: keyPath] = Page(
      page: page.page,
      isAtEnd: page.isAtEnd,
      items: (items + page.items).uniqued()
    )
  }
}
