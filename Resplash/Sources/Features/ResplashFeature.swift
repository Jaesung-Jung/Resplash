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
    var selectedTab: Tab = .home

    var home = HomeFeature.State()
    var explore = ExploreFeature.State()
    var search = SearchFeature.State()

    var homePath = StackState<ResplashNavigationPath.State>()
    var explorePath = StackState<ResplashNavigationPath.State>()
    var searchPath = StackState<ResplashNavigationPath.State>()
  }

  enum Action: BindableAction {
    case home(HomeFeature.Action)
    case explore(ExploreFeature.Action)
    case search(SearchFeature.Action)
    case binding(BindingAction<State>)

    case homePath(StackActionOf<ResplashNavigationPath>)
    case explorePath(StackActionOf<ResplashNavigationPath>)
    case searchPath(StackActionOf<ResplashNavigationPath>)
  }

  enum Tab {
    case home
    case explore
    case search

    var keyPath: WritableKeyPath<State, StackState<ResplashNavigationPath.State>> {
      switch self {
      case .home:
        return \.homePath
      case .explore:
        return \.explorePath
      case .search:
        return \.searchPath
      }
    }
  }

  var body: some ReducerOf<Self> {
    BindingReducer()
    Scope(state: \.home, action: \.home) {
      HomeFeature()
    }
    Scope(state: \.explore, action: \.explore) {
      ExploreFeature()
    }
    Scope(state: \.search, action: \.search) {
      SearchFeature()
    }
    Reduce { state, action in
      switch action {
      case .home(.navigate(.collections)):
        let collectionsState = ImageCollectionsFeature.State(mediaType: state.home.mediaType)
        state.homePath.append(.collections(collectionsState))
        return .none

      case .home(.navigate(.collection(let collection))):
        let imagesState = ImagesFeature.State(item: .collection(collection))
        state.homePath.append(.images(imagesState))
        return .none

      case .home(.navigate(.topic(let topic))):
        let imagesState = ImagesFeature.State(item: .topic(topic))
        state.homePath.append(.images(imagesState))
        return .none

      case .home(.navigate(.image(let image))):
        let imageDetailState = ImageDetailFeature.State(image: image)
        state.homePath.append(.imageDetail(imageDetailState))
        return .none

      case .home:
        return .none

      case .explore(.navigate(.images(let category))):
        let imagesState = ImagesFeature.State(item: .category(category))
        state.explorePath.append(.images(imagesState))
        return .none

      case .explore(.navigate(.imageDetail(let image))):
        let imageDetailState = ImageDetailFeature.State(image: image)
        state.explorePath.append(.imageDetail(imageDetailState))
        return .none

      case .explore:
        return .none

      case .search(.navigate(.search(let query))):
        let searchResultState = SearchResultFeature.State(query: query)
        state.searchPath.append(.search(searchResultState))
        return .none

      case .search:
        return .none

      case .binding:
        return .none

      case .homePath(let path), .explorePath(let path), .searchPath(let path):
        switch path {
        case .element(id: _, action: .collections(.navigate(.collection(let collection)))):
          let collectionState = ImagesFeature.State(item: .collection(collection))
          state[keyPath: state.selectedTab.keyPath].append(.images(collectionState))
          return .none

        case .element(id: _, action: .images(.navigate(.image(let image)))):
          let imageDetailState = ImageDetailFeature.State(image: image)
          state[keyPath: state.selectedTab.keyPath].append(.imageDetail(imageDetailState))
          return .none

        case .element(id: _, action: .imageDetail(.navigate(.image(let image)))):
          let imageDetailState = ImageDetailFeature.State(image: image)
          state[keyPath: state.selectedTab.keyPath].append(.imageDetail(imageDetailState))
          return .none

        case .element(id: _, action: .imageDetail(.navigate(.search(let query)))):
          let searchResultState = SearchResultFeature.State(query: query)
          state[keyPath: state.selectedTab.keyPath].append(.search(searchResultState))
          return .none

        case .element:
          return .none

        case .push:
          return .none

        case .popFrom:
          return .none
        }
      }
    }
    .forEach(\.homePath, action: \.homePath)
    .forEach(\.explorePath, action: \.explorePath)
    .forEach(\.searchPath, action: \.searchPath)
  }
}
