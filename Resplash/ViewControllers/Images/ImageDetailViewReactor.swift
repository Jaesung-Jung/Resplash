//
//  ImageDetailViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/13/25.
//

import RxSwift
import ReactorKit
import Dependencies

final class ImageDetailViewReactor: Reactor {
  @Dependency(\.unsplashService) var unsplash

  let initialState: State

  init(imageAsset: ImageAsset) {
    self.initialState = State(imageAsset: imageAsset)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchImageDetail:
      let fetch = unsplash
        .imageDetail(for: currentState.imageAsset)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        fetch.map { .setImageDetail($0) },
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setImageDetail(let imageAssetDetail):
      return state.with {
        $0.imageDetail = imageAssetDetail
      }
    case .setLoading(let isLoading):
      return state.with {
        $0.isLoading = isLoading
      }
    }
  }
}

// MARK: - ImageDetailViewReactor.State

extension ImageDetailViewReactor {
  struct State: Then {
    let imageAsset: ImageAsset
    var imageDetail: ImageAssetDetail?
    var isLoading = false
  }
}

// MARK: - ImageDetailViewReactor.Action

extension ImageDetailViewReactor {
  enum Action {
    case fetchImageDetail
  }
}

// MARK: - ImageDetailViewReactor.Mutation

extension ImageDetailViewReactor {
  enum Mutation {
    case setImageDetail(ImageAssetDetail)
    case setLoading(Bool)
  }
}
