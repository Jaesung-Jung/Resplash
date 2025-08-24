//
//  ImageDetailFeature.swift
//  Resplash
//
//  Created by 정재성 on 8/24/25.
//

import OSLog
import Algorithms
import ComposableArchitecture

@Reducer
struct ImageDetailFeature {
  @ObservableState
  struct State: Equatable {
    let image: ImageAsset
    var detail: ImageAssetDetail?
    var seriesImages: [ImageAsset]?
    var activityState: ActivityState = .idle

    var relatedImages: [ImageAsset]?
    var page: Int = 1
    var hasNextPage: Bool = false
  }

  enum Action {
    case fetchDetail
    case fetchNextRelatedImages
    case fetchDetailResponse(Result<(ImageAssetDetail, [ImageAsset], Page<[ImageAsset]>), Error>)
    case fetchNextRelatedImagesResponse(Result<Page<[ImageAsset]>, Error>)
  }

  @Dependency(\.unsplash) var unsplash
  @Dependency(\.logger) var logger

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchDetail:
        state.activityState = .reloading
        return .run { [image = state.image] send in
          async let fetchDetail = unsplash.imageDetail(for: image)
          async let fetchSeriesImages = unsplash.seriesImages(for: image)
          async let fetchRelatedImages = unsplash.relatedImages(for: image, page: 1)
          do {
            let (detail, seriesImages, relatedImages) = try await (fetchDetail, fetchSeriesImages, fetchRelatedImages)
            await send(.fetchDetailResponse(.success((detail, seriesImages, relatedImages))))
          } catch {
            await send(.fetchDetailResponse(.failure(error)))
          }
        }

      case .fetchNextRelatedImages:
        guard state.hasNextPage, !state.activityState.isActive else {
          return .none
        }
        state.activityState = .loading
        return .run { [image = state.image, page = state.page] send in
          do {
            let relatedImages = try await unsplash.relatedImages(for: image, page: page + 1)
            await send(.fetchNextRelatedImagesResponse(.success(relatedImages)))
          } catch {
            await send(.fetchNextRelatedImagesResponse(.failure(error)))
          }
        }

      case .fetchDetailResponse(.success((let detail, let seriesImages, let relatedImages))):
        state.detail = detail
        state.seriesImages = seriesImages
        state.relatedImages = Array(relatedImages.uniqued(on: \.id))
        state.page = relatedImages.page
        state.hasNextPage = !relatedImages.isAtEnd
        state.activityState = .idle
        return .none

      case .fetchNextRelatedImagesResponse(.success(let relatedImages)):
        state.relatedImages = state.relatedImages.map { $0 + relatedImages }.map { Array($0.uniqued(on: \.id)) }
        state.page = relatedImages.page
        state.hasNextPage = !relatedImages.isAtEnd
        state.activityState = .idle
        return .none

      case .fetchDetailResponse(.failure(let error)), .fetchNextRelatedImagesResponse(.failure(let error)):
        logger.fault("\(error)")
        state.activityState = .idle
        return .none
      }
    }
  }
}
