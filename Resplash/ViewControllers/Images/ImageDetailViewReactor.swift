//
//  ImageDetailViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/13/25.
//

import RxSwift
import RxRelay
import RxFlow
import ReactorKit
import Dependencies
import Algorithms

final class ImageDetailViewReactor: BaseReactor {
  @Dependency(\.unsplashService) var unsplash

  let initialState: State

  init(image: ImageAsset) {
    self.initialState = State(image: image)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchImageDetail:
      let detail = unsplash
        .imageDetail(for: currentState.image)
        .asObservable()
      let relatedImages = unsplash
        .relatedImage(for: currentState.image, page: 1)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        .merge(
          detail.map { .setImageDetail($0) },
          relatedImages.map { .setRelatedImages($0) }
        ),
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .fetchNextRelatedImages:
      guard !currentState.isLoading && currentState.hasNextPage else {
        return .empty()
      }
      let page = currentState.page + 1
      let nextImages = unsplash
        .relatedImage(for: currentState.image, page: page)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        nextImages.map { .appendRelatedImages($0) },
        .just(.setLoading(false))
      )
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setImageDetail(let detail):
      return state.with {
        $0.detail = detail
      }
    case .setRelatedImages(let relatedImages):
      return state.with {
        $0.relatedImages = Array(relatedImages.uniqued())
        $0.page = relatedImages.page
        $0.hasNextPage = !relatedImages.isAtEnd
      }
    case .appendRelatedImages(let relatedImages):
      return state.with {
        $0.relatedImages = Array($0.relatedImages.appending(contentsOf: relatedImages).uniqued())
        $0.page = relatedImages.page
        $0.hasNextPage = !relatedImages.isAtEnd
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
    let image: ImageAsset
    var detail: ImageAssetDetail?

    @Pulse var relatedImages: [ImageAsset] = []
    var page: Int = 1
    var hasNextPage: Bool = false
    var isLoading: Bool = false
  }
}

// MARK: - ImageDetailViewReactor.Action

extension ImageDetailViewReactor {
  enum Action {
    case fetchImageDetail
    case fetchNextRelatedImages
  }
}

// MARK: - ImageDetailViewReactor.Mutation

extension ImageDetailViewReactor {
  enum Mutation {
    case setImageDetail(ImageAssetDetail)
    case setRelatedImages(Page<[ImageAsset]>)
    case appendRelatedImages(Page<[ImageAsset]>)
    case setLoading(Bool)
  }
}
