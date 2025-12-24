//
//  SearchFeature.swift
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
public struct SearchFeature {
  @ObservableState
  public struct State: Equatable {
    var query: String = ""

    var trends: [Unsplash.Trend]?
    var suggestions: [Unsplash.SearchSuggestion]?

    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    public init() {
    }
  }

  public enum Action {
    case fetchTrends
    case fetchSuggestion
    case fetchTrendsResponse(Result<[Unsplash.Trend], Error>)
    case fetchSuggestionResponse(Result<[Unsplash.SearchSuggestion], Error>)
    case updateQuery(String)

    case search
    case selectKeyword(Unsplash.Trend.Keyword)
    case selectSuggestion(Unsplash.SearchSuggestion)

    case navigate(Navigation)
  }

  public enum Navigation {
    case search(String)
  }

  enum CancelID {
    case suggestion
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchTrends:
        state.loading = .loading
        return .run { [unsplash] send in
          let result = await Result { try await unsplash.search.trends(page: 1).items }
          await send(.fetchTrendsResponse(result))
        }

      case .fetchSuggestion:
        guard !state.query.isEmpty else {
          return .none
        }
        return .run { [unsplash, query = state.query] send in
          let result = await Result { try await unsplash.search.suggestions(query: query) }
          await send(.fetchSuggestionResponse(result))
        }
        .cancellable(id: CancelID.suggestion)

      case .fetchTrendsResponse(.success(let trends)):
        state.trends = trends
        state.loading = .none
        return .none

      case .fetchSuggestionResponse(.success(let suggestions)):
        state.suggestions = suggestions
        return .none

      case .fetchTrendsResponse(.failure(let error)), .fetchSuggestionResponse(.failure(let error)):
        state.loading = .none
        return .none

      case .updateQuery(let query):
        state.query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
          state.suggestions = nil
          return .cancel(id: CancelID.suggestion)
        }
        return .none

      case .search:
        return .send(.navigate(.search(state.query)))

      case .selectKeyword(let keyword):
        return .send(.navigate(.search(keyword.title)))

      case .selectSuggestion(let suggestion):
        return .send(.navigate(.search(suggestion.text)))

      case .navigate:
        return .none
      }
    }
  }
}
