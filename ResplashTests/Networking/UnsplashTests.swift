//
//  UnsplashTests.swift
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

import Testing
import Dependencies
@testable import Resplash

struct UnsplashTests {
  @Dependency(\.unsplash) var unsplash

  @Test(arguments: MediaType.allCases)
  func topics(mediaType: MediaType) async throws  {
    let topics = try await unsplash.topics(for: mediaType)
    #expect(!topics.isEmpty)
  }

  @Test func categories() async throws {
    let categories = try await unsplash.categories()
    #expect(!categories.isEmpty)
  }

  @Test func photos() async throws {
    let images = try await unsplash.photos(page: 1)
    #expect(!images.isEmpty)
  }

  @Test func illustrations() async throws {
    let images = try await unsplash.illustrations(page: 1)
    #expect(!images.isEmpty)
  }

  @Test func topicImages() async throws {
    let images = try await unsplash.images(for: Topic.preview, page: 1)
    #expect(!images.isEmpty)
  }

  @Test func collectionImages() async throws {
    let images = try await unsplash.images(for: ImageAssetCollection.preview, page: 1)
    #expect(!images.isEmpty)
  }

  @Test func categoryImages() async throws {
    let images = try await unsplash.images(for: Category.Item.preview, page: 1)
    #expect(!images.isEmpty)
  }

  @Test(arguments: MediaType.allCases)
  func collections(mediaType: MediaType) async throws {
    let collections = try await unsplash.collections(for: mediaType, page: 1)
    #expect(!collections.isEmpty)
  }

  @Test func imageDetail() async throws {
    _ = try await unsplash.imageDetail(for: .preview)
  }

  @Test func seriesImages() async throws {
    let images = try await unsplash.seriesImages(for: .preview)
    #expect(!images.isEmpty)
  }

  @Test func relatedImage() async throws {
    let images = try await unsplash.relatedImages(for: .preview, page: 1)
    #expect(!images.isEmpty)
  }

  @Test func searchSuggestion() async throws {
    _ = try await unsplash.searchSuggestion("")
  }

  @Test func searchPhotos() async throws {
    let images = try await unsplash.searchPhotos("", page: 1)
    #expect(!images.isEmpty)
  }

  @Test func searchIllustrations() async throws {
    let images = try await unsplash.searchIllustrations("", page: 1)
    #expect(!images.isEmpty)
  }

  @Test func searchCollections() async throws {
    let collections = try await unsplash.searchCollections("", page: 1)
    #expect(!collections.isEmpty)
  }

  @Test func searchUsers() async throws {
    let users = try await unsplash.searchUsers("", page: 1)
    #expect(!users.isEmpty)
  }

  @Test func searchTrends() async throws {
    let trends = try await unsplash.searchTrends()
    #expect(!trends.isEmpty)
  }

  @Test func searchMeta() async throws {
    _ = try await unsplash.searchMeta("")
  }
}
