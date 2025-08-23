//
//  ImageCollectionsView.swift
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

struct ImageCollectionsView: View {
  let store: StoreOf<ImageCollectionsFeature>

  var body: some View {
    ScrollView {
      if let collections = store.state.collections {
        LazyVGrid( columns: [GridItem(spacing: 10), GridItem()], spacing: 20) {
          ForEach(collections) { collection in
            Button {
              store.send(.navigateToImages(collection))
            } label: {
              ImageCollectionView(collection)
            }
            .foregroundStyle(.primary)
          }
        }
        .padding(20)

        LazyVStack {
          if store.state.hasNextPage {
            ProgressView()
              .foregroundStyle(.tertiary)
              .progressViewStyle(.app.circleScale())
              .onAppear {
                store.send(.fetchNext)
              }
          }
        }
      }
    }
    .navigationTitle("Collections")
    .task {
      store.send(.fetch)
    }
  }
}

// MARK: - ImageCollectionsView Preview

#Preview {
  NavigationStack {
    ImageCollectionsView(
      store: Store(initialState: ImageCollectionsFeature.State(mediaType: .photo)) {
        ImageCollectionsFeature()
      }
    )
  }
}
