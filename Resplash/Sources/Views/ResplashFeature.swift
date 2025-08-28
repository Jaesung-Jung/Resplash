//
//  ResplashFeature.swift
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

import ComposableArchitecture

@Reducer
struct ResplashFeature {
  @ObservableState
  struct State: Equatable {
    var selectedTab: Tab = .main

    var main = MainFeature.State()
    var explore = ExploreFeature.State()
    var search = SearchFeature.State()

    var mainPath = StackState<Path.State>()
    var explorePath = StackState<Path.State>()
    var searchPath = StackState<Path.State>()
  }

  enum Action {
    case main(MainFeature.Action)
    case explore(ExploreFeature.Action)
    case search(SearchFeature.Action)

    case selectTab(Tab)
    case mainPath(StackActionOf<Path>)
    case explorePath(StackActionOf<Path>)
    case searchPath(StackActionOf<Path>)
  }

  @Reducer(state: .equatable)
  enum Path {
    case collections(ImageCollectionsFeature)
    case images(ImagesFeature)
    case imageDetail(ImageDetailFeature)
    case searchResults(SearchResultsFeature)
  }

  enum Tab: Hashable {
    case main
    case explore
    case search
  }

  @Dependency(\.logger) var logger

  var body: some ReducerOf<Self> {
    Scope(state: \.main, action: \.main) {
      MainFeature()
    }
    Scope(state: \.explore, action: \.explore) {
      ExploreFeature()
    }
    Scope(state: \.search, action: \.search) {
      SearchFeature()
    }
    Reduce { state, action in
      switch action {
      case .main(.navigateToCollections(let mediaType)):
        state.mainPath.append(.collections(ImageCollectionsFeature.State(mediaType: mediaType)))
        return .none

      case .main(.navigateToImages(let item)):
        state.mainPath.append(.images(ImagesFeature.State(item: item)))
        return .none

      case .main(.navigateToImageDetail(let image)):
        state.mainPath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .main:
        return .none

      case .explore(.navigateToImages(let item)):
        state.explorePath.append(.images(ImagesFeature.State(item: item)))
        return .none

      case .explore(.navigateToImageDetail(let image)):
        state.explorePath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .explore:
        return .none

      case .search(.search(let query)):
        state.searchPath.append(.searchResults(SearchResultsFeature.State(query: query)))
        return .none

      case .search:
        return .none

      case .selectTab(let tab):
        state.selectedTab = tab
        return .none

      case .mainPath(.element(id: _, action: .collections(.navigateToImages(let collection)))):
        state.mainPath.append(.images(ImagesFeature.State(item: .collection(collection))))
        return .none

      case .mainPath(.element(id: _, action: .images(.navigateToImageDetail(let image)))):
        state.mainPath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .mainPath(.element(id: _, action: .imageDetail(.navigateToImageDetail(let image)))):
        state.mainPath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .explorePath(.element(id: _, action: .collections(.navigateToImages(let collection)))):
        state.explorePath.append(.images(ImagesFeature.State(item: .collection(collection))))
        return .none

      case .explorePath(.element(id: _, action: .images(.navigateToImageDetail(let image)))):
        state.explorePath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .explorePath(.element(id: _, action: .imageDetail(.navigateToImageDetail(let image)))):
        state.explorePath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .searchPath(.element(id: _, action: .collections(.navigateToImages(let collection)))):
        state.searchPath.append(.images(ImagesFeature.State(item: .collection(collection))))
        return .none

      case .searchPath(.element(id: _, action: .images(.navigateToImageDetail(let image)))):
        state.searchPath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .searchPath(.element(id: _, action: .imageDetail(.navigateToImageDetail(let image)))):
        state.searchPath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .mainPath, .explorePath, .searchPath:
        return .none
      }
    }
    .forEach(\.mainPath, action: \.mainPath)
    .forEach(\.explorePath, action: \.explorePath)
    .forEach(\.searchPath, action: \.searchPath)
    ._printChanges()
  }
}
