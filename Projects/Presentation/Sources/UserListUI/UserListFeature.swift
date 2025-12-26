//
//  UserListFeature.swift
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
public struct UserListFeature {
  @ObservableState
  public struct State: Equatable {
    public let query: String
    public var users: [Unsplash.User]?

    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    var page = 1
    var hasNextPage = false

    public init(query: String) {
      self.query = query
    }
  }

  public enum Action {
    case fetchUsers
    case fetchNextUsers
    case fetchUsersResponse(Result<Page<Unsplash.User>, Error>)
    case fetchNextUsersResponse(Result<Page<Unsplash.User>, Error>)

    case navigate(Navigation)
  }

  public enum Navigation {
    case userProfile(Unsplash.User)
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchUsers:
        state.loading = .loading
        return .run { [unsplash, query = state.query] send in
          let result = await Result { try await unsplash.search.users(query: query, page: 1) }
          await send(.fetchUsersResponse(result))
        }

      case .fetchNextUsers:
        guard state.hasNextPage, !state.isLoading else {
          return .none
        }
        state.loading = .loadingMore
        return .run { [unsplash, query = state.query, page = state.page] send in
          let result = await Result { try await unsplash.search.users(query: query, page: page + 1) }
          await send(.fetchUsersResponse(result))
        }

      case .fetchUsersResponse(.success(let users)):
        state.loading = .none
        state.users = Array(users.uniqued())
        state.page = users.page
        state.hasNextPage = !users.isAtEnd
        return .none

      case .fetchNextUsersResponse(.success(let users)):
        state.loading = .none
        state.users = state.users.map { $0 + users }.map { Array($0.uniqued()) }
        state.page = users.page
        state.hasNextPage = !users.isAtEnd
        return .none

      case .fetchUsersResponse(.failure(let error)), .fetchNextUsersResponse(.failure(let error)):
        return .none

      case .navigate:
        return .none
      }
    }
  }
}
