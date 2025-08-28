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

import OSLog
import Algorithms
import ComposableArchitecture

@Reducer
struct SearchFeature {
  @ObservableState
  struct State: Equatable {
    var query: String = ""

    var trends: [Trend]?
    var suggestion: SearchSuggestion?

    var activityState: ActivityState = .idle
  }

  enum Action {
    case fetchTrends
    case fetchSuggestion(String)
    case fetchTrendsResponse(Result<[Trend], Error>)
    case fetchSuggestionResponse(Result<SearchSuggestion, Error>)

    case search(String)
  }

  @Reducer(state: .equatable)
  enum Path {
    case search(SearchResultsFeature)
    case imageDetail(ImageDetailFeature)
  }

  enum CancelID {
    case fetchSuggestion
  }

  @Dependency(\.unsplash) var unsplash
  @Dependency(\.logger) var logger

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchTrends:
        state.activityState = .loading
        return .run { send in
          do {
            let trends = try await unsplash.searchTrends()
            await send(.fetchTrendsResponse(.success(trends)))
          } catch {
            await send(.fetchTrendsResponse(.failure(error)))
          }
        }

      case .fetchSuggestion(let query):
        state.query = query
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else {
          state.suggestion = nil
          return .none
        }
        return .run { send in
          do {
            print("searchSuggestion")
            let suggestion = try await unsplash.searchSuggestion(trimmedQuery)
            await send(.fetchSuggestionResponse(.success(suggestion)))
          } catch {
            await send(.fetchSuggestionResponse(.failure(error)))
          }
        }
        .debounce(id: CancelID.fetchSuggestion, for: .milliseconds(300), scheduler: DispatchQueue.main)
        .cancellable(id: CancelID.fetchSuggestion)

      case .fetchTrendsResponse(.success(let trends)):
        state.trends = trends
        state.activityState = .idle
        return .none

      case .fetchSuggestionResponse(.success(let suggestion)):
        state.suggestion = suggestion
        return .none

      case .fetchTrendsResponse(.failure(let error)), .fetchSuggestionResponse(.failure(let error)):
        logger.fault("\(error)")
        state.activityState = .idle
        return .none

      case .search:
        return .none
      }
    }
  }
}
