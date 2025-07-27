//
//  MainViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/8/25.
//

import Foundation
import RxSwift
import RxRelay
import RxFlow
import ReactorKit
import Dependencies
import Algorithms

final class MainViewReactor: BaseReactor {
  @Dependency(\.unsplashService) var unsplash

  let initialState = State()

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .selectMediaType(let mediaType):
      return .just(.setMediaType(mediaType))

    case .fetch:
      guard !currentState.isLoading else {
        return .empty()
      }
      let topics = unsplash
        .topics(for: currentState.mediaType)
        .asObservable()
      let collections = unsplash
        .collections(for: currentState.mediaType, page: 1)
        .asObservable()
      let images = unsplash
        .images(for: currentState.mediaType, page: 1)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        .merge(
          topics.map { .setTopics($0) },
          collections.map { .setCollections($0) },
          images.map { .setImages($0) }
        ),
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .fetchNextImages:
      guard !currentState.isLoading, currentState.hasNextPage else {
        return .empty()
      }
      let page = currentState.page + 1
      let nextImages = unsplash
        .images(for: currentState.mediaType, page: page)
        .asObservable()
      return .concat(
        .just(.setLoading(true)),
        nextImages.map { .appendImages($0) },
        .just(.setLoading(false))
      )

    case .navigateToCollection(let mediaType):
      steps.accept(AppStep.collections(mediaType))
      return .empty()

    case .navigateToTopicImages(let topic):
      steps.accept(AppStep.topicImages(topic))
      return .empty()

    case .navigateToCollectionImages(let collection):
      steps.accept(AppStep.collectionImages(collection))
      return .empty()

    case .navigateToImageDetail(let image):
      steps.accept(AppStep.imageDetail(image))
      return .empty()

    case .share(let url):
      steps.accept(AppStep.share(url))
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setMediaType(let mediaType):
      return state.with {
        $0.mediaType = mediaType
      }

    case .setTopics(let topics):
      return state.with {
        $0.topics = topics
      }

    case .setCollections(let collections):
      return state.with {
        $0.collections = Array(collections.uniqued())
      }

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

  func transform(action: Observable<Action>) -> Observable<Action> {
    action.flatMap { action -> Observable<Action> in
      if case .selectMediaType = action {
        return .concat(.just(action), .just(.fetch))
      }
      return .just(action)
    }
  }
}

// MARK: - MainViewReactor.State

extension MainViewReactor {
  struct State: Then {
    @Pulse var topics: [Topic] = []
    @Pulse var collections: [ImageAssetCollection] = []
    @Pulse var images: [ImageAsset] = []

    var mediaType: MediaType = .photo
    var page = 1
    var hasNextPage = false
    var isLoading = false
  }
}

// MARK: - MainViewReactor.Action

extension MainViewReactor {
  enum Action {
    case selectMediaType(MediaType)
    case fetch
    case fetchNextImages

    case navigateToCollection(MediaType)
    case navigateToTopicImages(Topic)
    case navigateToCollectionImages(ImageAssetCollection)
    case navigateToImageDetail(ImageAsset)
    case share(URL)
  }
}

// MARK: - MainViewReactor.Mutation

extension MainViewReactor {
  enum Mutation {
    case setMediaType(MediaType)
    case setTopics([Topic])
    case setCollections(Page<[ImageAssetCollection]>)
    case setImages(Page<[ImageAsset]>)
    case appendImages(Page<[ImageAsset]>)
    case setLoading(Bool)
  }
}
