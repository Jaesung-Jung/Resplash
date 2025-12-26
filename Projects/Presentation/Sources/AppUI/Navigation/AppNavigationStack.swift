//
//  AppNavigationStack.swift
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
import ResplashCollectionListUI
import ResplashImageListUI
import ResplashImageDetailUI
import ResplashImageMapUI
import ResplashSearchResultUI
import ResplashUserListUI
import ResplashUserProfileUI

struct AppNavigationStack<Root: View>: View {
  let path: Binding<Store<StackState<AppNavigationPath.State>, StackActionOf<AppNavigationPath>>>
  let root: Root

  init(path: Binding<Store<StackState<AppNavigationPath.State>, StackActionOf<AppNavigationPath>>>, @ViewBuilder root: () -> Root) {
    self.path = path
    self.root = root()
  }

  var body: some View {
    NavigationStack(path: path) {
      root
    } destination: { store in
      switch store.case {
      case .collections(let store):
        CollectionListView(store: store)
      case .images(let store):
        ImageListView(store: store)
      case .imageDetail(let store):
        ImageDetailView(store: store)
      case .imageMap(let store):
        ImageMapView(store: store)
      case .searchResult(let store):
        SearchResultView(store: store)
      case .users(let store):
        UserListView(store: store)
      case .userProfile(let store):
        UserProfileView(store: store)
      }
    }
  }
}
