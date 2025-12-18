//
//  UnsplashClient+Live.swift
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

import ResplashClients
import ResplashEntities
import ResplashNetworking

extension UnsplashClient {
  public static func makeClient(_ request: @Sendable @escaping (Endpoint) async throws -> NetworkClient.DataResponse) -> UnsplashClient {
    return UnsplashClient(
      fetchTopics: {
        try await request(.topics())
          .decode([DTO<TopicTransformer>].self)
          .map(\.domain)
      },
      fetchTopicImages: {
        Page(
          page: $1,
          pageSize: $2,
          items: try await request(.topicImages(for: $0, page: $1, count: $2))
            .decode([DTO<AssetTransformer>].self)
            .map(\.domain)
        )
      },
      fetchCategories: {
        try await request(.categories())
          .decode([DTO<CategoryTransformer>].self)
          .map(\.domain)
      },
      fetchCategoryImages: {
        Page(
          page: $1,
          pageSize: $2,
          items: try await request(.categoryImages(for: $0, page: $1, count: $2))
            .decode([DTO<AssetTransformer>].self, forKey: "photos")
            .map(\.domain)
        )
      },
      fetchCollections: {
        Page(
          page: $1,
          pageSize: $2,
          items: try await request(.assetCollections(for: $0, page: $1, count: $2))
            .decode([DTO<AssetCollectionTransformer>].self)
            .map(\.domain)
        )
      },
      fetchCollectionImages: {
        Page(
          page: $1,
          pageSize: $2,
          items: try await request(.assetCollectionImages(for: $0, page: $1, count: $2))
            .decode([DTO<AssetTransformer>].self)
            .map(\.domain)
        )
      },
      fetchPhotos: {
        Page(
          page: $0,
          pageSize: $1,
          items: try await request(.photos(page: $0, count: $1))
            .decode([DTO<AssetTransformer>].self)
            .map(\.domain)
        )
      },
      fetchIllustrations: {
        Page(
          page: $0,
          pageSize: $1,
          items: try await request(.illustrations(page: $0, count: $1))
            .decode([DTO<AssetTransformer>].self)
            .map(\.domain)
        )
      },
      fetchRelatedImages: {
        Page(
          page: $1,
          pageSize: $2,
          items: try await request(.relatedImages(for: $0, page: $1, count: $2))
            .decode([DTO<AssetTransformer>].self, forKey: "results")
            .map(\.domain)
        )
      },
      fetchSeriesImages: {
        try await request(.seriesImages(for: $0))
          .decode([DTO<AssetTransformer>].self)
          .map(\.domain)
      },
      fetchImageDetail: {
        try await request(.detail(for: $0))
          .decode(DTO<AssetDetailTransformer>.self)
          .domain
      },
      fetchTrends: {
        Page(
          page: $0,
          pageSize: $1,
          items: try await request(.trends(page: $0, count: $1))
            .decode([DTO<TrendTransformer>].self)
            .map(\.domain)
        )
      },
      fetchMeta: {
        try await request(.searchMeta(query: $0))
          .decode(DTO<SearchMetaTransformer>.self)
          .domain
      },
      searchPhotos: {
        Page(
          page: $1,
          pageSize: $2,
          items: try await request(.searchPhotos(query: $0, page: $1, count: $2))
            .decode([DTO<AssetTransformer>].self, forKey: "results")
            .map(\.domain)
        )
      },
      searchIllustrations: {
        Page(
          page: $1,
          pageSize: $2,
          items: try await request(.searchIllustrations(query: $0, page: $1, count: $2))
            .decode([DTO<AssetTransformer>].self, forKey: "results")
            .map(\.domain)
        )
      },
      searchCollections: {
        Page(
          page: $1,
          pageSize: $2,
          items: try await request(.searchCollections(query: $0, page: $1, count: $2))
            .decode([DTO<AssetCollectionTransformer>].self, forKey: "results")
            .map(\.domain)
        )
      },
      searchUsers: {
        Page(
          page: $1,
          pageSize: $2,
          items: try await request(.searchUsers(query: $0, page: $1, count: $2))
            .decode([DTO<UserTransformer>].self, forKey: "results")
            .map(\.domain)
        )
      }
    )
  }
}
