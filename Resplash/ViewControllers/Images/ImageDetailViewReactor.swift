//
//  ImageDetailViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/13/25.
//

import RxSwift
import ReactorKit
import Dependencies
import Algorithms

final class ImageDetailViewReactor: Reactor {
  @Dependency(\.unsplashService) var unsplash

  let initialState: State

  init(imageAsset: ImageAsset) {
    self.initialState = State(imageAsset: imageAsset)
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchImageDetail:
      let detail = unsplash
        .imageDetail(for: currentState.imageAsset)
        .asObservable()
      let relatedImages = unsplash
        .relatedImage(for: currentState.imageAsset, page: 1)
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
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setImageDetail(let imageAssetDetail):
      return state.with {
        $0.imageDetail = imageAssetDetail
      }
    case .setRelatedImages(let relatedImages):
      return state.with {
        $0.relatedImages = Array(relatedImages.uniqued())
        $0.page = relatedImages.page
        $0.hasNextPage = !relatedImages.isAtEnd
      }
    case .appendRelatedImages(let relatedImages):
      return state.with {
        $0.relatedImages.append(contentsOf: relatedImages.uniqued())
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
    let imageAsset: ImageAsset
    var imageDetail: ImageAssetDetail?

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
