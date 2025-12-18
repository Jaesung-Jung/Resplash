//
//  AssetClient.swift
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

import ResplashEntities

extension UnsplashClient {
  public struct AssetClient {
    let fetchPhotos: @Sendable (Int, Int) async throws -> Page<Asset>
    let fetchIllustrations: @Sendable (Int, Int) async throws -> Page<Asset>
    let fetchRelatedImages: @Sendable (Asset, Int, Int) async throws -> Page<Asset>
    let fetchSeriesImages: @Sendable (Asset) async throws -> [Asset]
    let fetchImageDetail: @Sendable (Asset) async throws -> AssetDetail

    @inlinable
    public func images(for mediaType: MediaType, page: Int) async throws -> Page<Asset> {
      switch mediaType {
      case .photo:
        try await photos(page: page)
      case .illustration:
        try await illustrations(page: page)
      }
    }

    public func photos(page: Int) async throws -> Page<Asset> {
      try await fetchPhotos(page, 30)
    }

    public func illustrations(page: Int) async throws -> Page<Asset> {
      try await fetchIllustrations(page, 30)
    }

    public func relatedImages(for asset: Asset, page: Int) async throws -> Page<Asset> {
      try await fetchRelatedImages(asset, page, 20)
    }

    public func seriesImages(for asset: Asset) async throws -> [Asset] {
      try await fetchSeriesImages(asset)
    }

    public func detail(for asset: Asset) async throws -> AssetDetail {
      try await fetchImageDetail(asset)
    }
  }
}

extension UnsplashClient.AssetClient: Sendable{
}
