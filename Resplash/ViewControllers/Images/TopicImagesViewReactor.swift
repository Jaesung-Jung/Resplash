//
//  TopicImagesViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/10/25.
//

import RxSwift
import ReactorKit
import Dependencies
import IdentifiedCollections

final class TopicImagesViewReactor: Reactor {
  @Dependency(\.unsplashService) var unsplash

  let initialState: State

  init(topic: Topic) {
    self.initialState = State(topic: topic)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchImages:
      guard !currentState.isLoading else {
        return .empty()
      }
      let images = unsplash.images(for: currentState.topic, page: 1)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        images.map { .setImages(IdentifiedArray(uniqueElements: $0), 1) },
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .fetchNextImages:
      guard !currentState.isLoading && currentState.hasNext else {
        return .empty()
      }
      let page = currentState.page + 1
      let nextImages = unsplash
        .images(for: currentState.topic, page: page)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        nextImages.map { .appendImages(IdentifiedArray(uniqueElements: $0), page) },
        .just(.setLoading(false))
      )
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setImages(let images, let page):
      return state.with {
        $0.images = images
        $0.page = page
        $0.hasNext = images.count >= 30
      }
    case .appendImages(let images, let page):
      return state.with {
        $0.images.append(contentsOf: images)
        $0.page = page
        $0.hasNext = images.count >= 30
      }
    case .setLoading(let isLoading):
      return state.with {
        $0.isLoading = isLoading
      }
    }
  }
}

// MARK: - TopicImagesViewReactor.State

extension TopicImagesViewReactor {
  struct State: Then {
    let topic: Topic
    @Pulse var images: IdentifiedArrayOf<ImageAsset> = []

    var page: Int = 1
    var hasNext: Bool = true

    var isLoading = false
  }
}

// MARK: - TopicImagesViewReactor.Action

extension TopicImagesViewReactor {
  enum Action {
    case fetchImages
    case fetchNextImages
  }
}

// MARK: - TopicImagesViewReactor.Mutation

extension TopicImagesViewReactor {
  enum Mutation {
    case setImages(IdentifiedArrayOf<ImageAsset>, Int)
    case appendImages(IdentifiedArrayOf<ImageAsset>, Int)
    case setLoading(Bool)
  }
}
