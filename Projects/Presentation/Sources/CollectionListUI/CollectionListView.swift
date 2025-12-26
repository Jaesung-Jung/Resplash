//
//  CollectionListView.swift
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
import ResplashUI
import ResplashEntities
import ResplashStrings
import ResplashDesignSystem

public struct CollectionListView: View {
  @Environment(\.layoutEnvironment) var layoutEnvironment
  let store: StoreOf<CollectionListFeature>

  public init(store: StoreOf<CollectionListFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      if let collections = store.collections {
        LazyVGrid( columns: [GridItem(spacing: 10), GridItem()], spacing: 20) {
          ForEach(collections) { collection in
            Button {
              store.send(.navigate(.images(collection)))
            } label: {
              ImageCollectionView(collection)
            }
            .buttonStyle(.ds.plain())
          }
        }
        .padding(layoutEnvironment.contentInsets([.top, .horizontal]))

        LazyVStack {
          if store.hasNextPage {
            LoadingProgressView()
              .onAppear {
                store.send(.fetchNextCollections)
              }
          }
        }
      }
    }
    .navigationTitle(navigationTitle(for: store.method))
    .task {
      store.send(.fetchCollections)
    }
  }
}

// MARK: - CollectionListView (ViewBuilders)

extension CollectionListView {
  @inlinable func navigationTitle(for method: CollectionListFeature.FetchMethod) -> Text {
    switch method {
    case .media:
      Text(.localizable(.imageCollections))
    case .search(let query):
      Text(query)
    }
  }
}

// MARK: - CollectionListView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  NavigationStack {
    CollectionListView(store: Store(initialState: CollectionListFeature.State(mediaType: .photo)) {
      CollectionListFeature()
    } withDependencies: {
      $0.unsplash = .preview()
    })
  }
}

#endif
