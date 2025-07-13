//
//  ImageDetailViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/13/25.
//

import RxSwift
import ReactorKit

final class ImageDetailViewReactor: Reactor {
  let initialState: State

  init(imageAsset: ImageAsset) {
    self.initialState = State(imageAsset: imageAsset)
  }

  func mutate(action: Action) -> Observable<Mutation> {
  }

  func reduce(state: State, mutation: Mutation) -> State {
  }
}

// MARK: - ImageDetailViewReactor.State

extension ImageDetailViewReactor {
  struct State: Then {
    let imageAsset: ImageAsset
  }
}

// MARK: - ImageDetailViewReactor.Action

extension ImageDetailViewReactor {
  enum Action {
  }
}

// MARK: - ImageDetailViewReactor.Mutation

extension ImageDetailViewReactor {
  enum Mutation {
  }
}
