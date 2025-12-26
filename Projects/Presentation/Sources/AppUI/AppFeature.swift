//
//  AppFeature.swift
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
import ResplashHomeUI
import ResplashExploreUI
import ResplashSearchUI
import ResplashCollectionListUI
import ResplashImageListUI
import ResplashImageDetailUI
import ResplashImageMapUI
import ResplashSearchResultUI
import ResplashUserListUI
import ResplashUserProfileUI

@Reducer
public struct AppFeature {
  @ObservableState
  public struct State: Equatable {
    var selectedTab: Tab = .home

    var home = HomeFeature.State()
    var explore = ExploreFeature.State()
    var search = SearchFeature.State()

    var homePath = StackState<AppNavigationPath.State>()
    var explorePath = StackState<AppNavigationPath.State>()
    var searchPath = StackState<AppNavigationPath.State>()

    public init() {}
  }

  public enum Action: BindableAction {
    case home(HomeFeature.Action)
    case explore(ExploreFeature.Action)
    case search(SearchFeature.Action)
    case binding(BindingAction<State>)

    case homePath(StackActionOf<AppNavigationPath>)
    case explorePath(StackActionOf<AppNavigationPath>)
    case searchPath(StackActionOf<AppNavigationPath>)
  }

  enum Tab {
    case home
    case explore
    case search

    var keyPath: WritableKeyPath<State, StackState<AppNavigationPath.State>> {
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

  public init() {}

  public var body: some ReducerOf<Self> {
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
        let collectionListState = CollectionListFeature.State(mediaType: state.home.mediaType)
        state.homePath.append(.collections(collectionListState))
        return .none

      case .home(.navigate(.topicImages(let topic))):
        let imageListState = ImageListFeature.State(item: .topic(topic))
        state.homePath.append(.images(imageListState))
        return .none

      case .home(.navigate(.collectionImages(let collection))):
        let imageListState = ImageListFeature.State(item: .collection(collection))
        state.homePath.append(.images(imageListState))
        return .none

      case .home(.navigate(.imageDetail(let image))):
        let imageDetailState = ImageDetailFeature.State(image: image)
        state.homePath.append(.imageDetail(imageDetailState))
        return .none

      case .explore:
        return .none

      case .search(.navigate(.search(let query))):
        let searchResultState = SearchResultFeature.State(query: query, mediaType: state.home.mediaType)
        state.searchPath.append(.searchResult(searchResultState))
        return .none

      case .homePath(.element(id: _, let action)):
        return handleStackNavigationAction(action, state: &state, path: \.homePath)

      case .explorePath(.element(id: _, let action)):
        return handleStackNavigationAction(action, state: &state, path: \.explorePath)

      case .searchPath(.element(id: _, let action)):
        return handleStackNavigationAction(action, state: &state, path: \.searchPath)

      case .binding:
        return .none

      default:
        return .none
      }
    }
    .forEach(\.homePath, action: \.homePath)
    .forEach(\.explorePath, action: \.explorePath)
    .forEach(\.searchPath, action: \.searchPath)
  }

  func handleStackNavigationAction(_ action: AppNavigationPath.Action, state: inout State, path: WritableKeyPath<State, StackState<AppNavigationPath.State>>) -> Effect<Action> {
    switch action {
    case .collections(.navigate(.images(let collection))), .searchResult(.navigate(.collectionImages(let collection))):
      let imageListState = ImageListFeature.State(item: .collection(collection))
      state[keyPath: path].append(.images(imageListState))
    case .images(.navigate(.imageDetail(let image))), .imageDetail(.navigate(.imageDetail(let image))), .searchResult(.navigate(.imageDetail(let image))):
      let imageDetailState = ImageDetailFeature.State(image: image)
      state[keyPath: path].append(.imageDetail(imageDetailState))
    case .imageDetail(.navigate(.imageMap(let image))):
      let imageMapState = ImageMapFeature.State(image: image)
      state[keyPath: path].append(.imageMap(imageMapState))
    case .searchResult(.navigate(.search(let query, let mediaType))):
      let searchResultState = SearchResultFeature.State(query: query, mediaType: mediaType)
      state[keyPath: path].append(.searchResult(searchResultState))
    case .searchResult(.navigate(.users(let query))):
      let userListState = UserListFeature.State(query: query)
      state[keyPath: path].append(.users(userListState))
    case .searchResult(.navigate(.userProfile(let user))):
      let userProfileState = UserProfileFeature.State(user: user)
      state[keyPath: path].append(.userProfile(userProfileState))
    case .searchResult(.navigate(.collections(let query))):
      let collectionListState = CollectionListFeature.State(query: query)
      state[keyPath: path].append(.collections(collectionListState))
    default:
      return .none
    }
    return .none
  }
}
