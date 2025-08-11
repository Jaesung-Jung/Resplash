//
//  SearchResultViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/30/25.
//

import RxSwift
import RxRelay
import RxFlow
import ReactorKit
import Dependencies
import Algorithms

final class SearchResultViewReactor: BaseReactor {
  @Dependency(\.unsplashService) var unsplash

  let initialState: State

  init(query: String) {
    self.initialState = State(query: query)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .search:
      guard !currentState.isLoading else {
        return .empty()
      }
      let search = unsplash.searchPhotos(currentState.query, page: 1).asObservable()
      return .concat(
        .just(.setLoading(true)),
        search.map { .setImages($0) },
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .searchNext:
      guard !currentState.isLoading, currentState.hasNextPage else {
        return .empty()
      }
      let page = currentState.page + 1
      let search = unsplash.searchPhotos(currentState.query, page: page).asObservable()
      return .concat(
        .just(.setLoading(true)),
        search.map { .appendImages($0) },
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setImages(let images):
      return state.with {
        $0.images = Array(images.uniqued())
        $0.page = images.page
        $0.hasNextPage = !images.isAtEnd
      }

    case .appendImages(let images):
      return state.with {
        $0.images = Array($0.images.appending(contentsOf: images).uniqued())
        $0.page = images.page
        $0.hasNextPage = !images.isAtEnd
      }

    case .setLoading(let isLoading):
      return state.with {
        $0.isLoading = isLoading
      }
    }
  }
}

// MARK: - SearchResultViewReactor.State

extension SearchResultViewReactor {
  struct State: Then {
    @Pulse var images: [ImageAsset] = []

    let query: String
    var page: Int = 1
    var hasNextPage: Bool = false
    var isLoading: Bool = false
  }
}

// MARK: - SearchResultViewReactor.Action

extension SearchResultViewReactor {
  enum Action {
    case search
    case searchNext
  }
}

// MARK: - SearchResultViewReactor.Mutation

extension SearchResultViewReactor {
  enum Mutation {
    case setImages(Page<[ImageAsset]>)
    case appendImages(Page<[ImageAsset]>)
    case setLoading(Bool)
  }
}
