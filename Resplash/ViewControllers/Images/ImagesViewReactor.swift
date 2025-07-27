//
//  ImagesViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/27/25.
//

import RxSwift
import RxRelay
import RxFlow
import ReactorKit
import Algorithms

final class ImagesViewReactor: BaseReactor {
  private let fetchImages: (Int) -> Single<Page<[ImageAsset]>>

  let initialState: State

  init(title: String, images: @escaping (Int) -> Single<Page<[ImageAsset]>>) {
    self.fetchImages = images
    self.initialState = State(title: title)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchImages:
      guard !currentState.isLoading else {
        return .empty()
      }
      let images = fetchImages(1).asObservable()
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
      let nextImages = fetchImages(page).asObservable()
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

// MARK: - ImagesViewReactor.State

extension ImagesViewReactor {
  struct State: Then {
    let title: String
    @Pulse var images: [ImageAsset] = []

    var page: Int = 1
    var hasNextPage: Bool = false
    var isLoading: Bool = false
  }
}

// MARK: - ImagesViewReactor.Action

extension ImagesViewReactor {
  enum Action {
    case fetchImages
    case fetchNextImages

    case navigateToImageDetail(ImageAsset)
  }
}

// MARK: - ImagesViewReactor.Mutation

extension ImagesViewReactor {
  enum Mutation {
    case setImages(Page<[ImageAsset]>)
    case appendImages(Page<[ImageAsset]>)
    case setLoading(Bool)
  }
}
