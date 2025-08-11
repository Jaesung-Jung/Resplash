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
      return .concat(
        .just(.setMediaType(mediaType)),
        .just(.setLoading(true)),
        fetch(mediaType: mediaType),
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .refresh:
      guard !currentState.isLoading else {
        return .empty()
      }
      return .concat(
        .just(.setRefreshing(true)),
        fetch(mediaType: currentState.mediaType),
        .just(.setRefreshing(false)).delay(.milliseconds(500), scheduler: MainScheduler.instance)
      )
      .catchAndReturn(.setRefreshing(false))

    case .fetch:
      guard !currentState.isLoading else {
        return .empty()
      }
      return .concat(
        .just(.setLoading(true)),
        fetch(mediaType: currentState.mediaType),
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .fetchNextImages:
      guard !currentState.isLoading, !currentState.isRefreshing, currentState.hasNextPage else {
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

    case .setRefreshing(let isRefreshing):
      return state.with {
        $0.isRefreshing = isRefreshing
      }
    }
  }
}

// MARK: - MainViewReactor (Private)

extension MainViewReactor {
  private func fetch(mediaType: MediaType) -> Observable<Mutation> {
    let topics = unsplash
      .topics(for: mediaType)
      .asObservable()
    let collections = unsplash
      .collections(for: mediaType, page: 1)
      .asObservable()
    let images = unsplash
      .images(for: mediaType, page: 1)
      .asObservable()
    return .merge(
      topics.map { .setTopics($0) },
      collections.map { .setCollections($0) },
      images.map { .setImages($0) }
    )
  }
}

// MARK: - MainViewReactor.State

extension MainViewReactor {
  struct State: Then {
    @Pulse var topics: [Topic] = []
    @Pulse var collections: [ImageAssetCollection] = []
    @Pulse var images: [ImageAsset] = []

    var mediaType: MediaType = .photo
    var page: Int = 1
    var hasNextPage: Bool = false
    var isLoading: Bool = false
    var isRefreshing: Bool = false
  }
}

// MARK: - MainViewReactor.Action

extension MainViewReactor {
  enum Action {
    case selectMediaType(MediaType)
    case refresh
    case fetch
    case fetchNextImages
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
    case setRefreshing(Bool)
  }
}
