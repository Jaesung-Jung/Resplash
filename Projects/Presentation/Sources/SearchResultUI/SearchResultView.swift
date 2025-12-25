//
//  SearchResultView.swift
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

public struct SearchResultView: View {
  @Environment(\.layoutEnvironment) var layoutEnvironment
  @Bindable var store: StoreOf<SearchResultFeature>

  @State var item = "Item 1"

  public init(store: StoreOf<SearchResultFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
        Section {
          switch store.searchType {
          case .photo:
            if let photos = store.photos {
              imageList(photos.items)
            } else {
              emptyView()
            }
          case .illustration:
            if let illustrations = store.illustrations {
              imageList(illustrations.items)
            } else {
              emptyView()
            }
          case .collection:
            if let collections = store.collections {
              collectionList(collections.items)
            } else {
              emptyView()
            }
          case .user:
            if let users = store.users {
              userList(users.items)
            } else {
              emptyView()
            }
          }

          if store.hasNextPage {
            LoadingProgressView()
              .onAppear {
                store.send(.fetchNextItems)
              }
          }
        } header: {
          if let meta = store.searchMeta, !meta.relatedSearches.isEmpty {
            relatedSearchList(meta.relatedSearches)
          }
        }
      }
      .padding(layoutEnvironment.contentInsets(.vertical))
    }
    .buttonStyle(.ds.plain())
    .navigationTitle(store.query)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Picker("", selection: .constant("Photos")) {
          Text("Photos")
            .tag("Photos")
          Text("Illustration")
            .tag("Illustration")
        }
        .pickerStyle(.menu)
      }
    }
    .task {
      store.send(.fetchItems)
    }
  }
}

// MARK: - SearchResultView (ViewBuilders)

extension SearchResultView {
  @ViewBuilder func relatedSearchList(_ keywords: [String]) -> some View {
    ScrollView(.horizontal) {
      GlassEffectContainer(spacing: 8) {
        HStack {
          ForEach(keywords, id: \.self) { keyword in
            Button {
            } label: {
              Text("#\(keyword)")
                .foregroundStyle(.secondary)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .frame(minWidth: 60)
            }
            .buttonStyle(.glass)
            .transition(.move(edge: .leading))
          }
        }
      }
      .padding(layoutEnvironment.contentInsets(.horizontal))
    }
    .scrollIndicators(.hidden)
    .scrollClipDisabled()
  }

  @ViewBuilder func imageList(_ images: [Unsplash.Image]) -> some View {
    MansonryGrid(images, columns: 2, spacing: 2) { image in
      Button {
        // store.send(.navigate(.imageDetail(image)))
      } label: {
        ImageItemView(image)
          .size(.compact)
      }
      .buttonStyle(.ds.plain())
    } size: {
      CGSize(width: $0.width, height: $0.height)
    }
  }

  @ViewBuilder func collectionList(_ collections: [Unsplash.ImageCollection]) -> some View {
  }

  @ViewBuilder func userList(_ users: [Unsplash.User]) -> some View {
  }

  @ViewBuilder func emptyView() -> some View {
  }
}

// MARK: - SearchView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  NavigationStack {
    SearchResultView(store: Store(initialState: SearchResultFeature.State(query: "Lake", mediaType: .photo)) {
      SearchResultFeature()
    } withDependencies: {
      $0.unsplash = .preview()
    })
  }
}

#endif
