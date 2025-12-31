//
//  ExploreView.swift
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

public struct ExploreView: View {
  @Environment(\.layoutEnvironment) var layoutEnvironment
  let store: StoreOf<ExploreFeature>

  public init(store: StoreOf<ExploreFeature>) {
    self.store = store
  }

  @ViewBuilder func section<Content: View>(_ title: Text, @ViewBuilder content: () -> Content) -> some View {
    VStack(spacing: 10) {
      HStack(spacing: 0) {
        title
          .font(.title2)
          .fontWeight(.bold)
        Spacer(minLength: 0)
      }
      .padding(layoutEnvironment.contentInsets(.horizontal))

      content()
    }
  }

  public var body: some View {
    ScrollView {
      LazyVStack(spacing: 40) {
        if let categories = store.categories {
          ForEach(categories) { category in
            section(Text(category.title)) {
              ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(), GridItem()]) {
                  ForEach(category.items) { item in
                    Button {
                      store.send(.navigate(.categoryImages(item)))
                    } label: {
                      CategoryItemView(item)
                        .containerRelativeFrame(.horizontal) { length, _ in (length - 50) / 2 }
                    }
                  }
                }
                .padding(layoutEnvironment.contentInsets(.horizontal))
              }
            }
          }
        }

        if let images = store.images {
          section(Text("Popular Images")) {
            MansonryGrid(images, columns: 2, spacing: 2) { image in
              Button {
                store.send(.navigate(.imageDetail(image)))
              } label: {
                ImageItemView(image)
                  .size(.compact)
              }
            } size: {
              CGSize(width: $0.width, height: $0.height)
            }
            .padding(layoutEnvironment.contentInsets(.horizontal))
          }

          if store.hasNextPage {
            LoadingProgressView()
              .onAppear {
                store.send(.fetchNext)
              }
          }
        }
      }
    }
    .buttonStyle(.ds.plain())
    .navigationTitle(.localizable(.explore))
    .task {
      store.send(.fetch)
    }
  }
}

// MARK: - ExploreView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  NavigationStack {
    ExploreView(store: Store(initialState: ExploreFeature.State()) {
      ExploreFeature()
    } withDependencies: {
      $0.unsplash = .preview()
    })
    .navigationTitle(.localizable(.explore))
  }
}

#endif
