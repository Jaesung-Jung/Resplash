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
      print("🚀 action: \(action)")
      defer {
        print("🚀 searchPath: \(state.searchPath.count)")
      }
      switch action {
      case .home(.navigate(.collections)):
        state.homePath.append(.collections(ImageCollectionsFeature.State(mediaType: state.home.mediaType)))
        return .none

      case .home(.navigate(.collection(let collection))):
        state.homePath.append(.images(ImagesFeature.State(item: .collection(collection))))
        return .none

      case .home(.navigate(.topic(let topic))):
        state.homePath.append(.images(ImagesFeature.State(item: .topic(topic))))
        return .none

      case .home(.navigate(.image(let image))):
        state.homePath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .homePath(.element(id: _, action: .collections(.navigate(.collection(let collection))))):
        state.homePath.append(.images(ImagesFeature.State(item: .collection(collection))))
        return .none

      case .homePath(.element(id: _, action: .images(.navigate(.image(let image))))):
        state.homePath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .homePath(.element(id: _, action: .imageDetail(.navigate(.image(let image))))):
        state.homePath.append(.imageDetail(ImageDetailFeature.State(image: image)))
        return .none

      case .search(.navigate(.search(let query))):
        state.searchPath.append(.search(SearchResultFeature.State(query: query)))
        return .none

      default:
        return .none
      }
    }
    .forEach(\.homePath, action: \.homePath)
    .forEach(\.explorePath, action: \.explorePath)
    .forEach(\.searchPath, action: \.searchPath)
  }
}
