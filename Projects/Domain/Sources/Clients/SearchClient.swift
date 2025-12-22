//
//  SearchClient.swift
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
  public struct SearchClient: Sendable {
    let fetchTrends: @Sendable (Int, Int) async throws -> Page<Unsplash.Trend>
    let fetchMeta: @Sendable (String) async throws -> Unsplash.SearchMeta
    let searchPhotos: @Sendable (String, Int, Int) async throws -> Page<Unsplash.Image>
    let searchIllustrations: @Sendable (String, Int, Int) async throws -> Page<Unsplash.Image>
    let searchCollections: @Sendable (String, Int, Int) async throws -> Page<Unsplash.ImageCollection>
    let searchUsers: @Sendable (String, Int, Int) async throws -> Page<Unsplash.User>

    public func trends(page: Int, count: Int) async throws -> Page<Unsplash.Trend> {
      try await fetchTrends(page, count)
    }

    public func meta(query: String) async throws -> Unsplash.SearchMeta {
      try await fetchMeta(query)
    }

    public func photos(query: String, page: Int, count: Int) async throws -> Page<Unsplash.Image> {
      try await searchPhotos(query, page, count)
    }

    public func illustrations(query: String, page: Int, count: Int) async throws -> Page<Unsplash.Image> {
      try await searchIllustrations(query, page, count)
    }

    public func collections(query: String, page: Int, count: Int) async throws -> Page<Unsplash.ImageCollection> {
      try await searchCollections(query, page, count)
    }

    public func users(query: String, page: Int, count: Int) async throws -> Page<Unsplash.User> {
      try await searchUsers(query, page, count)
    }
  }
}
