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
      if let meta = store.searchMeta {
        LazyVStack(spacing: 40, pinnedViews: [.sectionHeaders]) {
          Section {
            if let users = store.users, !users.isEmpty {
              sectionItem(title: .localizable(.users), subtitle: formattedNumber(meta.users)) {
                store.send(.navigate(.users(store.query)))
              } content: {
                UserCardHGrid(users: users, insets: layoutEnvironment.contentInsets(.horizontal)) {
                  store.send(.navigate(.userProfile($0)))
                }
              }
            }

            if let collections = store.collections, !collections.isEmpty {
              sectionItem(title: .localizable(.imageCollections), subtitle: formattedNumber(meta.collections)) {
                store.send(.navigate(.collections(store.query)))
              } content: {
                ImageCollectionHGrid(collections, insets: layoutEnvironment.contentInsets(.horizontal)) {
                  store.send(.navigate(.collectionImages($0)))
                }
              }
            }

            if let images = store.images, !images.isEmpty {
              sectionItem(title: .localizable(.images), subtitle: formattedNumber(meta.images(for: store.mediaType))) {
                imageList(images) {
                  store.send(.navigate(.imageDetail($0)))
                }
              }

              if store.state.hasNextPage {
                LoadingProgressView()
                  .onAppear {
                    store.send(.fetchNextImages)
                  }
              }
            }
          } header: {
            if !meta.relatedSearches.isEmpty {
              relatedSearchList(meta.relatedSearches) {
                store.send(.navigate(.search($0, store.mediaType)))
              }
            }
          }
        }
        .padding(layoutEnvironment.contentInsets(.vertical))
      }
    }
    .navigationTitle(store.query.capitalized)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      MediaPickerMenu(mediaType: $store.mediaType.sending(\.selectMediaType))
    }
    .task {
      store.send(.fetchContents)
    }
  }
}

// MARK: - SearchResultView (ViewBuilders)

extension SearchResultView {
  @ViewBuilder func relatedSearchList(_ keywords: [String], action: @MainActor @escaping (String) -> Void) -> some View {
    ScrollView(.horizontal) {
      GlassEffectContainer(spacing: 8) {
        HStack {
          ForEach(keywords, id: \.self) { keyword in
            Button {
              action(keyword)
            } label: {
              Text(keyword)
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

  @ViewBuilder func sectionItem<Content: View>(title titleKey: LocalizedStringKey, subtitle: String, action: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content) -> some View {
    VStack(spacing: 10) {
      if let action {
        Button {
          action()
        } label: {
          SectionTitle(titleKey, subtitle: subtitle, disclosureIndicator: true)
            .padding(layoutEnvironment.contentInsets(.horizontal))
        }
      } else {
        SectionTitle(titleKey, subtitle: subtitle, disclosureIndicator: false)
          .padding(layoutEnvironment.contentInsets(.horizontal))
      }

      content()
    }
    .buttonStyle(.ds.plain())
  }

  @ViewBuilder func imageList(_ images: [Unsplash.Image], action: @MainActor @escaping (Unsplash.Image) -> Void) -> some View {
    MansonryGrid(images, columns: 2, spacing: 10) { image in
      Button {
        action(image)
      } label: {
        ImageItemView(image)
          .size(.compact)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
    } size: {
      CGSize(width: $0.width, height: $0.height)
    }
    .padding(layoutEnvironment.contentInsets(.horizontal))
  }

  @ViewBuilder func emptyView() -> some View {
  }

  @inlinable func formattedNumber(_ number: Int) -> String {
    number.formatted(.number.notation(.compactName))
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
