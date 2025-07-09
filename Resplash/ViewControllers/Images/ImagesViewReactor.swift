//
//  ImagesViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/8/25.
//

import Foundation
import RxSwift
import ReactorKit
import Dependencies
import IdentifiedCollections

// MARK: - ImagesViewReactor

final class ImagesViewReactor: Reactor {
  @Dependency(\.unsplashService) var unsplash

  let initialState = State()

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .selectMediaType(let mediaType):
      return .just(.setMediaType(mediaType))

    case .fetchImages:
      guard !currentState.isLoading else {
        return .empty()
      }
      let collections = unsplash
        .collections(for: currentState.mediaType, page: 1)
        .asObservable()
      let images = unsplash
        .images(for: currentState.mediaType, page: 1)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        .merge(
          collections.map { .setCollections($0) },
          images.map { .setImages($0, 1) }
        ),
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .fetchNextImages:
      guard !currentState.isLoading, currentState.hasNext else {
        return .empty()
      }
      let page = currentState.page + 1
      let nextImages = unsplash
        .images(for: currentState.mediaType, page: page)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        nextImages.map { .appendImages($0, page) },
        .just(.setLoading(false))
      )
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setMediaType(let mediaType):
      return state.with {
        $0.mediaType = mediaType
      }
    case .setCollections(let collections):
      return state.with {
        $0.collections = IdentifiedArray(uniqueElements: collections)
      }
    case .setImages(let images, let page):
      return state.with {
        $0.images = IdentifiedArray(uniqueElements: images)
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

  func transform(action: Observable<Action>) -> Observable<Action> {
    action.flatMap { action -> Observable<Action> in
      if case .selectMediaType = action {
        return .concat(.just(action), .just(.fetchImages))
      }
      return .just(action)
    }
  }
}

// MARK: - ImagesViewReactor.State

extension ImagesViewReactor {
  struct State: Then {
    @Pulse var collections: IdentifiedArrayOf<ImageAssetCollection> = []
    @Pulse var images: IdentifiedArrayOf<ImageAsset> = []

    var mediaType: MediaType = .photo
    var page: Int = 1
    var hasNext: Bool = true

    var isLoading: Bool = false
  }
}

// MARK: - ImagesViewReactor.Action

extension ImagesViewReactor {
  enum Action {
    case selectMediaType(MediaType)
    case fetchImages
    case fetchNextImages
  }
}

// MARK: - ImagesViewReactor.Mutation

extension ImagesViewReactor {
  enum Mutation {
    case setMediaType(MediaType)
    case setCollections([ImageAssetCollection])
    case setImages([ImageAsset], Int)
    case appendImages([ImageAsset], Int)
    case setLoading(Bool)
  }
}
