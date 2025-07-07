//
//  ImagesViewModel.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import Foundation
import Combine
import Dependencies

final class ImagesViewModel: ViewModel {
  @Published
  private(set) var state = State()

  @Published
  private(set) var error: Error?

  @Dependency(\.unsplashService) var unsplash

  func perform(_ action: Action) {
    switch action {
    case .fetchImages:
      updateState { $0.isLoading = true }
      unsplash.collections(for: .photo, page: 1) { [weak self] result1 in
        guard let self else {
          return
        }
        switch result1 {
        case .success(let collections):
          unsplash.images(for: .photo, page: 1) { [weak self] result2 in
            guard let self else {
              return
            }
            switch result2 {
            case .success(let images):
              updateState {
                $0.collections = collections
                $0.images = images
                $0.isLoading = false
              }
            case .failure(let failure):
              error = failure
            }
          }
        case .failure(let failure):
          error = failure
        }
      }

    case .fetchNextImages:
      let page = state.currentImagePage + 1
      unsplash.images(for: .photo, page: page) { [weak self] in
        self?.updateState(with: $0) {
          $0.images.append(contentsOf: $1)
          $0.currentImagePage = page
        }
      }
    }
  }

  @inlinable func setState(_ newState: State) {
    state = newState
  }

  @inlinable func setError(_ error: any Error) {
    self.error = error
  }
}

// MARK: - ImagesViewModel.State

extension ImagesViewModel {
  struct State {
    var currentImagePage: Int = 1
    var images: [ImageAsset] = []
    var collections: [ImageAssetCollection] = []

    var isLoading: Bool = false
  }
}

// MARK: - ImagesViewModel.Action

extension ImagesViewModel {
  enum Action {
    case fetchImages
    case fetchNextImages
  }
}
