//
//  ImageClient.swift
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
  public struct ImageClient: Sendable {
    let fetchPhotos: @Sendable (Int, Int) async throws -> Page<Unsplash.Image>
    let fetchIllustrations: @Sendable (Int, Int) async throws -> Page<Unsplash.Image>
    let fetchRelatedImages: @Sendable (Unsplash.Image, Int, Int) async throws -> Page<Unsplash.Image>
    let fetchSeriesImages: @Sendable (Unsplash.Image) async throws -> [Unsplash.Image]
    let fetchImageDetail: @Sendable (Unsplash.Image) async throws -> Unsplash.ImageDetail

    @inlinable
    public func images(for mediaType: Unsplash.MediaType, page: Int) async throws -> Page<Unsplash.Image> {
      switch mediaType {
      case .photo:
        try await photos(page: page)
      case .illustration:
        try await illustrations(page: page)
      }
    }

    public func photos(page: Int) async throws -> Page<Unsplash.Image> {
      try await fetchPhotos(page, 30)
    }

    public func illustrations(page: Int) async throws -> Page<Unsplash.Image> {
      try await fetchIllustrations(page, 30)
    }

    public func relatedImages(for image: Unsplash.Image, page: Int) async throws -> Page<Unsplash.Image> {
      try await fetchRelatedImages(image, page, 20)
    }

    public func seriesImages(for image: Unsplash.Image) async throws -> [Unsplash.Image] {
      try await fetchSeriesImages(image)
    }

    public func detail(for image: Unsplash.Image) async throws -> Unsplash.ImageDetail {
      try await fetchImageDetail(image)
    }
  }
}
