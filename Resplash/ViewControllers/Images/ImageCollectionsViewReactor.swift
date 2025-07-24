//
//  ImageCollectionsViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/10/25.
//

import RxSwift
import ReactorKit
import Dependencies
import Algorithms

final class ImageCollectionsViewReactor: Reactor {
  @Dependency(\.unsplashService) var unsplash

  let initialState: State

  init(mediaType: MediaType) {
    self.initialState = State(mediaType: mediaType)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchCollections:
      guard !currentState.isLoading else {
        return .empty()
      }
      let images = unsplash.collections(for: currentState.mediaType, page: 1)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        images.map { .setCollections($0) },
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .fetchNextCollections:
      guard !currentState.isLoading && currentState.hasNext else {
        return .empty()
      }
      let page = currentState.page + 1
      let nextImages = unsplash
        .collections(for: currentState.mediaType, page: page)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        nextImages.map { .appendCollections($0) },
        .just(.setLoading(false))
      )
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setCollections(let collections):
      return state.with {
        $0.collections = Array(collections.uniqued())
        $0.page = collections.page
        $0.hasNext = !collections.isAtEnd
      }
    case .appendCollections(let collections):
      return state.with {
        $0.collections.append(contentsOf: collections.uniqued())
        $0.page = collections.page
        $0.hasNext = !collections.isAtEnd
      }
    case .setLoading(let isLoading):
      return state.with {
        $0.isLoading = isLoading
      }
    }
  }
}

// MARK: - ImageCollectionsViewReactor.State

extension ImageCollectionsViewReactor {
  struct State: Then {
    let mediaType: MediaType
    @Pulse var collections: [ImageAssetCollection] = []

    var page = 1
    var hasNext = false
    var isLoading = false
  }
}

// MARK: - ImageCollectionsViewReactor.Action

extension ImageCollectionsViewReactor {
  enum Action {
    case fetchCollections
    case fetchNextCollections
  }
}

// MARK: - ImageCollectionsViewReactor.Mutation

extension ImageCollectionsViewReactor {
  enum Mutation {
    case setCollections(Page<[ImageAssetCollection]>)
    case appendCollections(Page<[ImageAssetCollection]>)
    case setLoading(Bool)
  }
}
