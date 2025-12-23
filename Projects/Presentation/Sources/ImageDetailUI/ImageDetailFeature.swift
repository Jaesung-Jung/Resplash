//
//  ImageDetailFeature.swift
//
//  Copyright © 2025 Jaesung Jung. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SwiftUI
import ComposableArchitecture
import ResplashUI
import ResplashClients
import ResplashEntities
import ResplashUtils

@Reducer
public struct ImageDetailFeature {
  @ObservableState
  public struct State: Equatable {
    public var previewImage: UIImage?
    public let image: Unsplash.Image
    public var detail: Unsplash.ImageDetail?
    public var seriesImages: [Unsplash.Image]?
    public var relatedImages: [Unsplash.Image]?

    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    var page: Int = 1
    var hasNextPage: Bool = false

    public init(image: Unsplash.Image) {
      self.image = image
    }
  }

  public enum Action: BindableAction {
    case fetchImageDetail
    case fetchNextRelatedImages
    case fetchImageDetailResponse(Result<(Unsplash.ImageDetail, [Unsplash.Image], Page<Unsplash.Image>), Error>)
    case fetchNextRelatedImagesResponse(Result<Page<Unsplash.Image>, Error>)

    case navigate(Navigation)
    case binding(BindingAction<State>)
  }

  public enum Navigation {
    case search(String)
    case imageDetail(Unsplash.Image)
    case imageMap(Unsplash.ImageDetail)
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .fetchImageDetail:
        state.loading = .loading
        return .run { [unsplash, image = state.image] send in
          let result = await Result {
            async let fetchDetail = unsplash.image.detail(for: image)
            async let fetchSeriesImages = unsplash.image.seriesImages(for: image)
            async let fetchRelatedImages = unsplash.image.relatedImages(for: image, page: 1)
            return try await (fetchDetail, fetchSeriesImages, fetchRelatedImages)
          }
          await send(.fetchImageDetailResponse(result))
        }

      case .fetchNextRelatedImages:
        guard state.hasNextPage, !state.isLoading else {
          return .none
        }
        state.loading = .loadingMore
        return .run { [unsplash, image = state.image, page = state.page] send in
          let result = await Result { try await unsplash.image.relatedImages(for: image, page: page + 1) }
          await send(.fetchNextRelatedImagesResponse(result))
        }

      case .fetchImageDetailResponse(.success((let detail, let seriesImages, let relatedImages))):
        state.loading = .none
        state.detail = detail
        state.seriesImages = seriesImages
        state.relatedImages = Array(relatedImages.uniqued())
        state.page = relatedImages.page
        state.hasNextPage = !relatedImages.isAtEnd
        return .none

      case .fetchNextRelatedImagesResponse(.success(let relatedImages)):
        state.loading = .none
        state.relatedImages = state.relatedImages.map { $0 + relatedImages }.map { Array($0.uniqued()) }
        state.page = relatedImages.page
        state.hasNextPage = !relatedImages.isAtEnd
        return .none

      case .fetchImageDetailResponse(.failure(let error)), .fetchNextRelatedImagesResponse(.failure(let error)):
        state.loading = .none
        return .none

      case .navigate:
        return .none

      case .binding:
        return .none
      }
    }
  }
}
