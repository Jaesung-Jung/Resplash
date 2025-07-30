//
//  SearchViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/29/25.
//

import RxSwift
import RxRelay
import RxFlow
import ReactorKit
import Dependencies
import Algorithms

final class SearchViewReactor: BaseReactor {
  @Dependency(\.unsplashService) var unsplash

  let initialState = State()

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchTrends:
      let fetchTrends = unsplash.searchTrends().asObservable()
      return .concat(
        .just(.setLoading(true)),
        fetchTrends.map { .setTrends($0) },
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .search(let query):
      steps.accept(AppStep.search(query))
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setTrends(let trends):
      return state.with {
        $0.trends = trends
      }

    case .setSearching(let isSearching):
      return state.with {
        $0.isSearching = isSearching
      }

    case .setLoading(let isLoading):
      return state.with {
        $0.isLoading = isLoading
      }
    }
  }
}

// MARK: - SearchViewReactor.State

extension SearchViewReactor {
  struct State: Then {
    @Pulse var trends: [Trend] = []
    var isSearching: Bool = false
    var isLoading: Bool = false
  }
}

// MARK: - SearchViewReactor.Action

extension SearchViewReactor {
  enum Action {
    case fetchTrends
    case search(String)
  }
}

// MARK: - SearchViewReactor.Mutation

extension SearchViewReactor {
  enum Mutation {
    case setTrends([Trend])
    case setSearching(Bool)
    case setLoading(Bool)
  }
}
