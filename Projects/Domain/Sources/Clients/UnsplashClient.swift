//
//  UnsplashClient.swift
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

import Dependencies
import ResplashEntities

public struct UnsplashClient {
  public let topic: TopicClient
  public let category: CategoryClient
  public let collection: AssetCollectionClient
  public let asset: AssetClient
  public let search: SearchClient

  public init(
    fetchTopics: @Sendable @escaping () async throws -> [Topic],
    fetchTopicImages: @Sendable @escaping (Topic, Int, Int) async throws -> Page<Asset>,
    fetchCategories: @Sendable @escaping () async throws -> [Category],
    fetchCategoryImages: @Sendable @escaping (Category, Int, Int) async throws -> Page<Asset>,
    fetchCollections: @Sendable @escaping (MediaType, Int, Int) async throws -> Page<AssetCollection>,
    fetchCollectionImages: @Sendable @escaping (AssetCollection, Int, Int) async throws -> Page<Asset>,
    fetchPhotos: @Sendable @escaping (Int, Int) async throws -> Page<Asset>,
    fetchIllustrations: @Sendable @escaping (Int, Int) async throws -> Page<Asset>,
    fetchRelatedImages: @Sendable @escaping (Asset, Int, Int) async throws -> Page<Asset>,
    fetchSeriesImages: @Sendable @escaping (Asset) async throws -> [Asset],
    fetchImageDetail: @Sendable @escaping (Asset) async throws -> AssetDetail,
    fetchTrends: @Sendable @escaping (Int, Int) async throws -> Page<Trend>,
    fetchMeta: @Sendable @escaping (String) async throws -> SearchMeta,
    searchPhotos: @Sendable @escaping (String, Int, Int) async throws -> Page<Asset>,
    searchIllustrations: @Sendable @escaping (String, Int, Int) async throws -> Page<Asset>,
    searchCollections: @Sendable @escaping (String, Int, Int) async throws -> Page<AssetCollection>,
    searchUsers: @Sendable @escaping (String, Int, Int) async throws -> Page<User>
  ) {
    self.topic = TopicClient(
      fetchItems: fetchTopics,
      fetchImages: fetchTopicImages
    )
    self.category = CategoryClient(
      fetchItems: fetchCategories,
      fetchImages: fetchCategoryImages
    )
    self.collection = AssetCollectionClient(
      fetchItems: fetchCollections,
      fetchImages: fetchCollectionImages
    )
    self.asset = AssetClient(
      fetchPhotos: fetchPhotos,
      fetchIllustrations: fetchIllustrations,
      fetchRelatedImages: fetchRelatedImages,
      fetchSeriesImages: fetchSeriesImages,
      fetchImageDetail: fetchImageDetail
    )
    self.search = SearchClient(
      fetchTrends: fetchTrends,
      fetchMeta: fetchMeta,
      searchPhotos: searchPhotos,
      searchIllustrations: searchIllustrations,
      searchCollections: searchCollections,
      searchUsers: searchUsers
    )
  }
}

extension UnsplashClient: Sendable {
}

extension UnsplashClient: DependencyKey {
  public static let liveValue = UnsplashClient(
    fetchTopics: { fatalError("Unimplemented") },
    fetchTopicImages: { _, _, _ in fatalError("Unimplemented") },
    fetchCategories: { fatalError("Unimplemented") },
    fetchCategoryImages: { _, _, _ in fatalError("Unimplemented") },
    fetchCollections: { _, _, _ in fatalError("Unimplemented") },
    fetchCollectionImages: { _, _, _ in fatalError("Unimplemented") },
    fetchPhotos: { _, _ in fatalError("Unimplemented") },
    fetchIllustrations: { _, _ in fatalError("Unimplemented") },
    fetchRelatedImages: { _, _, _ in fatalError("Unimplemented") },
    fetchSeriesImages: { _ in fatalError("Unimplemented") },
    fetchImageDetail: { _ in fatalError("Unimplemented") },
    fetchTrends: { _, _ in fatalError("Unimplemented") },
    fetchMeta: { _ in fatalError("Unimplemented") },
    searchPhotos: { _, _, _ in fatalError("Unimplemented") },
    searchIllustrations: { _, _, _ in fatalError("Unimplemented") },
    searchCollections: { _, _, _ in fatalError("Unimplemented") },
    searchUsers: { _, _, _ in fatalError("Unimplemented") }
  )
}

extension DependencyValues {
  public var unsplash: UnsplashClient {
    get { self[UnsplashClient.self] }
    set { self[UnsplashClient.self] = newValue }
  }
}
