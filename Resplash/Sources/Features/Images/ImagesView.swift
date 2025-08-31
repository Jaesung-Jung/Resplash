//
//  ImagesView.swift
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

struct ImagesView: View {
  let store: StoreOf<ImagesFeature>

  @ViewBuilder func topicHeader(_ topic: Topic) -> some View {
    HStack {
      Text(topic.description.trimmingCharacters(in: .whitespacesAndNewlines))
        .fontWeight(.medium)
      Spacer()
    }
  }

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 20) {
        if case .topic(let topic) = store.state.item {
          topicHeader(topic)
        }
        if let images = store.state.images {
          MansonryGrid(images, columns: 2, spacing: 2) { image in
            Button {
              store.send(.delegate(.selectImage(image)))
            } label: {
              ImageAssetView(image, size: .compact)
            }
          } size: {
            CGSize(width: $0.width, height: $0.height)
          }

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
      .padding(.horizontal, 20)
    }
    .navigationTitle(store.state.title)
    .navigationSubtitle(store.state.subtitle)
    .toolbar {
      if let shareLink = store.state.shareLink {
        ShareLink(item: shareLink) {
          Image(systemName: "square.and.arrow.up")
        }
      }
    }
    .task {
      store.send(.fetch)
    }
  }
}

// MARK: - ImagesView Preview

#if DEBUG

#Preview {
  NavigationStack {
    ImagesView(
      store: Store(initialState: ImagesFeature.State(item: .topic(.preview))) {
        ImagesFeature()
      }
    )
  }
}

#endif
