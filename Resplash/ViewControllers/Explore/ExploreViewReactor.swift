//
//  ExploreViewReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/28/25.
//

import RxSwift
import RxRelay
import RxFlow
import ReactorKit
import Dependencies
import Algorithms

final class ExploreViewReactor: BaseReactor {
  @Dependency(\.unsplashService) var unsplash

  let initialState = State()

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .fetchCategories:
      let fetchCategories = unsplash.categories().asObservable()
      return .concat(
        .just(.setLoading(true)),
        fetchCategories.map { .setCategories($0) },
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .fetchPopularImages:
      guard !currentState.categories.isEmpty, !currentState.isLoading, currentState.hasNextPage else {
        return .empty()
      }
      let page = currentState.page + 1
      let fetchImages = unsplash.images(for: .photo, page: page).asObservable()
      return .concat(
        .just(.setLoading(true)),
        fetchImages.map { .appendPopularImages($0) },
        .just(.setLoading(false))
      )
      .catchAndReturn(.setLoading(false))

    case .navigateToImageDetail(let image):
      steps.accept(AppStep.imageDetail(image))
      return .empty()
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    switch mutation {
    case .setCategories(let categories):
      return state.with {
        $0.categories = categories
      }

    case .appendPopularImages(let images):
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
}

// MARK: - ExploreViewReactor.State

extension ExploreViewReactor {
  struct State: Then {
    @Pulse var categories: [Category] = []
    @Pulse var images: [ImageAsset] = []

    var page: Int = 0
    var hasNextPage: Bool = true
    var isLoading: Bool = false
  }
}

// MARK: - ExploreViewReactor.Action

extension ExploreViewReactor {
  enum Action {
    case fetchCategories
    case fetchPopularImages

    case navigateToImageDetail(ImageAsset)
  }
}

// MARK: - ExploreViewReactor.Mutation

extension ExploreViewReactor {
  enum Mutation {
    case setCategories([Category])
    case appendPopularImages(Page<[ImageAsset]>)
    case setLoading(Bool)
  }
}
