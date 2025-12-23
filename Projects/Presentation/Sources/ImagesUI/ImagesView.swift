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
import ResplashUI
import ResplashEntities
import ResplashDesignSystem

public struct ImagesView: View {
  @Environment(\.layoutEnvironment) var layoutEnvironment
  let store: StoreOf<ImagesFeature>

  public init(store: StoreOf<ImagesFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      LazyVStack(spacing: 20) {
        if case .topic(let topic) = store.item {
          HStack {
            Text(topic.description.trimmingCharacters(in: .whitespacesAndNewlines))
              .fontWeight(.medium)
            Spacer()
          }
          .padding(layoutEnvironment.contentInsets(.horizontal))
        }
        if let images = store.images {
          MansonryGrid(images, columns: 2, spacing: 2) { image in
            Button {
              store.send(.navigate(.imageDetail(image)))
            } label: {
              ImageItemView(image)
                .size(.compact)
            }
            .buttonStyle(.ds.plain())
          } size: {
            CGSize(width: $0.width, height: $0.height)
          }

          if store.state.hasNextPage {
            LoadingProgressView()
              .onAppear {
                store.send(.fetchNextImages)
              }
          }
        }
      }
      .padding(layoutEnvironment.contentInsets(.vertical))
    }
    .navigationTitle(title(store.item))
    .navigationSubtitle(subtitle(store.item) ?? "")
    .toolbar {
      if let shareLink = store.shareLink {
        ShareLink(item: shareLink) {
          Image(systemName: "square.and.arrow.up")
        }
      }
    }
    .task {
      store.send(.fetchImages)
    }
  }
}

// MARK: - ImagesView (Strings)

extension ImagesView {
  func title(_ item: ImagesFeature.Item) -> String {
    switch item {
    case .topic(let topic):
      topic.title
    case .category(let category):
      category.title
    case .collection(let collection):
      collection.title
    }
  }

  func subtitle( _ item: ImagesFeature.Item) -> LocalizedStringKey? {
    switch item {
    case .topic(let topic):
      topic.owners.first.map { .localizable(.createdBy($0.name)) }
    case .collection(let collection):
      .localizable(.createdBy(collection.user.name))
    default:
      nil
    }
  }
}

// MARK: - ImagesView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  NavigationStack {
    ImagesView(store: Store(initialState: ImagesFeature.State(item: .topic(.preview))) {
      ImagesFeature()
    } withDependencies: {
      $0.unsplash = .preview()
    })
  }
}

#endif
