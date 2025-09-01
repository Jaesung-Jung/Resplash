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

import Algorithms
import ComposableArchitecture

@Reducer
struct ImageDetailFeature {
  @ObservableState
  struct State: Equatable {
    let image: ImageAsset
    var detail: ImageAssetDetail?
    var seriesImages: [ImageAsset]?
    var loadingPhase: LoadingPhase = .idle

    var relatedImages: [ImageAsset]?
    var page: Int = 1
    var hasNextPage: Bool = false
  }

  enum Action {
    case fetchDetail
    case fetchNextRelatedImages
    case fetchDetailResponse(Result<(ImageAssetDetail, [ImageAsset], Page<[ImageAsset]>), Error>)
    case fetchNextRelatedImagesResponse(Result<Page<[ImageAsset]>, Error>)

    case navigate(Navigation)
  }

  enum Navigation {
    case search(String)
    case image(ImageAsset)
  }

  @Dependency(\.unsplash) var unsplash
  @Dependency(\.logger) var logger

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchDetail:
        state.loadingPhase = .initial
        return .run { [image = state.image] send in
          let result = await Result {
            async let fetchDetail = unsplash.imageDetail(for: image)
            async let fetchSeriesImages = unsplash.seriesImages(for: image)
            async let fetchRelatedImages = unsplash.relatedImages(for: image, page: 1)
            return try await (fetchDetail, fetchSeriesImages, fetchRelatedImages)
          }
          await send(.fetchDetailResponse(result))
        }

      case .fetchNextRelatedImages:
        guard state.hasNextPage, !state.loadingPhase.isLoading else {
          return .none
        }
        state.loadingPhase = .loading
        return .run { [image = state.image, page = state.page] send in
          let result = await Result { try await unsplash.relatedImages(for: image, page: page + 1) }
          await send(.fetchNextRelatedImagesResponse(result))
        }

      case .fetchDetailResponse(.success((let detail, let seriesImages, let relatedImages))):
        state.detail = detail
        state.seriesImages = seriesImages
        state.relatedImages = Array(relatedImages.uniqued(on: \.id))
        state.page = relatedImages.page
        state.hasNextPage = !relatedImages.isAtEnd
        state.loadingPhase = .idle
        return .none

      case .fetchNextRelatedImagesResponse(.success(let relatedImages)):
        state.relatedImages = state.relatedImages.map { $0 + relatedImages }.map { Array($0.uniqued(on: \.id)) }
        state.page = relatedImages.page
        state.hasNextPage = !relatedImages.isAtEnd
        state.loadingPhase = .idle
        return .none

      case .fetchDetailResponse(.failure(let error)), .fetchNextRelatedImagesResponse(.failure(let error)):
        logger.fault("\(error)")
        state.loadingPhase = .idle
        return .none

      case .navigate:
        return .none
      }
    }
  }
}
