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
import MapKit
import ComposableArchitecture
import ResplashUI
import ResplashClients
import ResplashEntities
import ResplashUtils

@Reducer
public struct ImageDetailFeature {
  @ObservableState
  public struct State: Equatable {
    public let image: Asset
    public var detail: AssetDetail?
    public var seriesImages: [Asset]?
    public var relatedImages: [Asset]?

    @ObservationStateIgnored
    public var mapCamera: MapCamera?
    public var mapCoordinate: CLLocationCoordinate2D? {
      detail
        .flatMap(\.location)
        .flatMap(\.position)
        .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
    public var mapImageURL: URL { image.url.s3 }
    public var mapLabel: String? { detail.flatMap(\.location).map(\.name) }

    var loading: Loading = .none
    var isLoading: Bool { loading != .none }

    var page: Int = 1
    var hasNextPage: Bool = false

    @Presents public var imageMap: ImageMapFeature.State?
    // @Presents var imageViewer: ImageViewerFeature.State?

    public init(image: Asset) {
      self.image = image
    }
  }

  public enum Action {
    case fetchImageDetail
    case fetchNextRelatedImages
    case fetchImageDetailResponse(Result<(AssetDetail, [Asset], Page<Asset>), Error>)
    case fetchNextRelatedImagesResponse(Result<Page<Asset>, Error>)

    case updateCamera(MapCamera)
    case presentImageMap
    case imageMap(PresentationAction<ImageMapFeature.Action>)
    // case presentImageViewer
    // case imageViewer(PresentationAction<ImageViewerFeature.Action>)
    case navigate(Navigation)
  }

  public enum Navigation {
    case search(String)
    case imageDetail(Asset)
  }

  @Dependency(\.unsplash) var unsplash

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchImageDetail:
        state.loading = .loading
        return .run { [unsplash, image = state.image] send in
          let result = await Result {
            async let fetchDetail = unsplash.asset.detail(for: image)
            async let fetchSeriesImages = unsplash.asset.seriesImages(for: image)
            async let fetchRelatedImages = unsplash.asset.relatedImages(for: image, page: 1)
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
          let result = await Result { try await unsplash.asset.relatedImages(for: image, page: page + 1) }
          await send(.fetchNextRelatedImagesResponse(result))
        }

      case .fetchImageDetailResponse(.success((let detail, let seriesImages, let relatedImages))):
        state.loading = .none
        state.detail = detail
        state.seriesImages = seriesImages
        state.relatedImages = Array(relatedImages.uniqued())
        state.page = relatedImages.page
        state.hasNextPage = !relatedImages.isAtEnd
        if let position = detail.location?.position {
          let coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
          state.mapCamera = MapCamera(centerCoordinate: coordinate, distance: 500)
        }
        return .none

      case .fetchNextRelatedImagesResponse(.success(let relatedImages)):
        state.loading = .none
        state.relatedImages = state.relatedImages.map { $0 + relatedImages }.map { Array($0.uniqued()) }
        state.page = relatedImages.page
        state.hasNextPage = !relatedImages.isAtEnd
        return .none

      case .fetchImageDetailResponse(.failure(let error)), .fetchNextRelatedImagesResponse(.failure(let error)):
        state.loading = .none
        print(error)
        return .none

      case .updateCamera(let camera):
        print("updateCaemra: \(camera)")
        state.mapCamera = camera
        return .none

//      case .presentImageViewer:
//        state.imageViewer = ImageViewerFeature.State(
//          image: state.image
//        )
//        return .none

      case .presentImageMap:
        if let camera = state.mapCamera, let coordinate = state.mapCoordinate {
          state.imageMap = ImageMapFeature.State(
            camera: camera,
            imageURL: state.mapImageURL,
            label: state.mapLabel,
            coordinate: coordinate
          )
        }
        return .none

      case .imageMap(.presented(.delegate(.updateCamera(let camera)))):
        return .send(.updateCamera(camera))

      case .imageMap:
        print("Dismiss")
        return .none

      // case .imageViewer:
      //   return .none

      case .navigate:
        return .none
      }
    }
    .ifLet(\.$imageMap, action: \.imageMap) {
      ImageMapFeature()
    }
    // .ifLet(\.$imageViewer, action: \.imageViewer) {
    //   ImageViewerFeature()
    // }
  }
}
