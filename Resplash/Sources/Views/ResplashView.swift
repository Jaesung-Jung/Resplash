//
//  ResplashView.swift
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

import SwiftUI
import ComposableArchitecture

struct ResplashView: View {
  typealias TabItem = ResplashFeature.Tab

  @Bindable var store: StoreOf<ResplashFeature>

  var body: some View {
    TabView(selection: $store.selectedTab.sending(\.selectTab)) {
      Tab("Image", systemImage: "photo.on.rectangle.angled", value: TabItem.main) {
        NavigationStack(path: $store.scope(state: \.mainPath, action: \.mainPath)) {
          MainView(store: store.scope(state: \.main, action: \.main))
        } destination: {
          destination($0)
        }
      }
      Tab("Explore", systemImage: "safari", value: TabItem.explore) {
        NavigationStack(path: $store.scope(state: \.explorePath, action: \.explorePath)) {
          ExploreView(store: store.scope(state: \.explore, action: \.explore))
        } destination: {
          destination($0)
        }
      }
      Tab(value: TabItem.search, role: .search) {
        NavigationStack(path: $store.scope(state: \.searchPath, action: \.searchPath)) {
          SearchView(store: store.scope(state: \.search, action: \.search))
        } destination: {
          destination($0)
        }
      }
    }
    .tabBarMinimizeBehavior(.onScrollDown)
  }

  @ViewBuilder func destination(_ store: Store<ResplashFeature.Path.State, ResplashFeature.Path.Action>) -> some View {
    switch store.case {
    case .collections(let store):
      ImageCollectionsView(store: store)
    case .images(let store):
      ImagesView(store: store)
    case .imageDetail(let store):
      ImageDetailView(store: store)
    case .searchResults(let store):
      SearchResultsView(store: store)
    }
  }
}

// MARK: - ResplashView Preview

#if DEBUG

#Preview {
  ResplashView(
    store: Store(initialState: ResplashFeature.State()) {
      ResplashFeature()
    }
  )
}

#endif
