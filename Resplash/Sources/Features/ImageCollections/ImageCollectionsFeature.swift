//
//  ImageCollectionsFeature.swift
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
struct ImageCollectionsFeature {
  @ObservableState
  struct State: Equatable {
    let mediaType: MediaType
    var collections: [ImageAssetCollection]?
    var loadingPhase: LoadingPhase = .idle

    var page: Int = 1
    var hasNextPage: Bool = false
  }

  enum Action {
    case fetch
    case fetchNext
    case fetchResponse(Result<Page<[ImageAssetCollection]>, Error>)
    case fetchNextResponse(Result<Page<[ImageAssetCollection]>, Error>)

    case delegate(Delegate)
  }

  enum Delegate {
    case selectImageCollection(ImageAssetCollection)
  }

  @Dependency(\.unsplash) var unsplash
  @Dependency(\.logger) var logger

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetch:
        state.loadingPhase = .initial
        return .run { [mediaType = state.mediaType] send in
          do {
            let collections = try await unsplash.collections(for: mediaType, page: 1)
            await send(.fetchResponse(.success(collections)))
          } catch {
            await send(.fetchResponse(.failure(error)))
          }
        }

      case .fetchNext:
        guard state.hasNextPage, !state.loadingPhase.isLoading else {
          return .none
        }
        state.loadingPhase = .loading
        return .run { [mediaType = state.mediaType, page = state.page] send in
          do {
            let collections = try await unsplash.collections(for: mediaType, page: page + 1)
            await send(.fetchNextResponse(.success(collections)))
          } catch {
            await send(.fetchNextResponse(.failure(error)))
          }
        }

      case .fetchResponse(.success(let collections)):
        state.collections = Array(collections.uniqued(on: \.id))
        state.page = collections.page
        state.hasNextPage = !collections.isAtEnd
        state.loadingPhase = .idle
        return .none

      case .fetchNextResponse(.success(let collections)):
        state.collections = state.collections.map { $0 + collections }.map { Array($0.uniqued(on: \.id)) }
        state.page = collections.page
        state.hasNextPage = !collections.isAtEnd
        state.loadingPhase = .idle
        return .none

      case .fetchResponse(.failure(let error)), .fetchNextResponse(.failure(let error)):
        logger.fault("\(error)")
        state.loadingPhase = .idle
        return .none

      case .delegate:
        return .none
      }
    }
  }
}
