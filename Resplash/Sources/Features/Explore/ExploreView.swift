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

struct ExploreView: View {
  let store: StoreOf<ExploreFeature>

  var body: some View {
    ScrollView {
      if let categories = store.state.categories {
        LazyVStack(spacing: 0) {
          ForEach(categories) { category in
            HStack(spacing: 0) {
              Text(category.title)
                .font(.title2)
                .fontWeight(.bold)
              Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            ScrollView(.horizontal) {
              LazyHGrid(rows: [GridItem(), GridItem()]) {
                ForEach(category.items) { item in
                  Button {
                    store.send(.navigateToImages(.category(item)))
                  } label: {
                    CategoryView(item)
                      .containerRelativeFrame(.horizontal) { length, _ in (length - 50) / 2 }
                      .lineLimit(1)
                  }
                }
              }
              .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .padding(.bottom, 40)
          }

          if let images = store.state.images {
            HStack(spacing: 0) {
              Text("Popular Images")
                .font(.title2)
                .fontWeight(.bold)
              Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            MansonryGrid(images, columns: 2, spacing: 2) { image in
              Button {
                store.send(.navigateToImageDetail(image))
              } label: {
                ImageAssetView(image, size: .compact)
              }
            } size: {
              CGSize(width: $0.width, height: $0.height)
            }
            .padding(.horizontal, 20)

            if store.state.hasNextPage {
              ProgressView()
                .foregroundStyle(.tertiary)
                .progressViewStyle(.circleScale)
                .onAppear {
                  store.send(.fetchNext)
                }
            }
          }
        }
      }
    }
    .navigationTitle("Explore")
    .task {
      store.send(.fetch)
    }
  }
}

// MARK: - ExploreView Preview

#if DEBUG

#Preview {
  ExploreView(
    store: Store(initialState: ExploreFeature.State()) {
      ExploreFeature()
    }
  )
}

#endif
