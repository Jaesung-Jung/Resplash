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
      case .home(.selectTopic(let topic)):
        return .none

      case .home(.selectCollection(let collection)):
        return .none

      case .home(.selectImage(let asset)):
        return .none

      case .explore:
        return .none

      case .search:
        return .none

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
}
