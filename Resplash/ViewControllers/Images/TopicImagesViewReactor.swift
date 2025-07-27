//
//  TopicImagesViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/10/25.
//

import RxSwift
import RxRelay
import RxFlow
import ReactorKit
import Dependencies
import Algorithms

final class TopicImagesViewReactor: BaseReactor {
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
        images.map { .setImages($0) },
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .fetchNextImages:
      guard !currentState.isLoading && currentState.hasNextPage else {
        return .empty()
      }
      let page = currentState.page + 1
      let nextImages = unsplash
        .images(for: currentState.topic, page: page)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        nextImages.map { .appendImages($0) },
        .just(.setLoading(false))
      )

    case .navigateToImageDetail(let image):
      steps.accept(AppStep.imageDetail(image))
      return .empty()
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
        $0.images.append(contentsOf: images.uniqued())
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

// MARK: - TopicImagesViewReactor.State

extension TopicImagesViewReactor {
  struct State: Then {
    let topic: Topic
    @Pulse var images: [ImageAsset] = []

    var page = 1
    var hasNextPage = false
    var isLoading = false
  }
}

// MARK: - TopicImagesViewReactor.Action

extension TopicImagesViewReactor {
  enum Action {
    case fetchImages
    case fetchNextImages

    case navigateToImageDetail(ImageAsset)
  }
}

// MARK: - TopicImagesViewReactor.Mutation

extension TopicImagesViewReactor {
  enum Mutation {
    case setImages(Page<[ImageAsset]>)
    case appendImages(Page<[ImageAsset]>)
    case setLoading(Bool)
  }
}
