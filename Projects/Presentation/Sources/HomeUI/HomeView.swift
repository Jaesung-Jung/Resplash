//
//  HomeView.swift
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

public struct HomeView: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.layoutEnvironment) var layoutEnvironment

  @Bindable var store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      LazyVStack(spacing: 40, pinnedViews: [.sectionHeaders]) {
        Section {
          if let collections = store.collections {
            VStack(spacing: 10) {
              Button {
                store.send(.navigate(.collections))
              } label: {
                SectionTitle(.localizable(.imageCollections), disclosureIndicator: true)
              }
              .padding(layoutEnvironment.contentInsets(.horizontal))
              .buttonStyle(.ds.plain())

              ImageCollectionGridView(collections, insets: layoutEnvironment.contentInsets(.horizontal)) {
                store.send(.navigate(.collectionImages($0)))
              }
            }
            .buttonStyle(.plain)
          }

          if let images = store.images {
            VStack(spacing: 10) {
              SectionTitle(.localizable(.featured))
                .padding(layoutEnvironment.contentInsets(.horizontal))

              imageList(images)
            }
            .buttonStyle(.plain)
          }

          if store.hasNextPage {
            LoadingProgressView()
              .onAppear {
                store.send(.fetchNextImages)
              }
          }
        } header: {
          if let topics = store.topics {
            topicList(topics)
          }
        }
      }
      .padding(layoutEnvironment.contentInsets(.bottom))
    }
    .navigationTitle(.localizable(.home))
    .toolbar {
      MediaPickerMenu(mediaType: $store.mediaType.sending(\.selectMediaType))
    }
    .task {
      store.send(.fetchContents)
    }
  }
}

// MARK: - HomeView (ViewBuilders)

extension HomeView {
  @ViewBuilder func topicList(_ topics: [Unsplash.Topic]) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
      GlassEffectContainer {
        LazyHStack(spacing: 8) {
          ForEach(topics) { topic in
            Button {
              store.send(.navigate(.topicImages(topic)))
            } label: {
              TopicView(topic)
                .glassEffect(.regular.interactive())
            }
          }
        }
        .padding(layoutEnvironment.contentInsets([.top, .horizontal]))
      }
    }
    .scrollClipDisabled()
    .buttonStyle(.plain)
  }

  @ViewBuilder func imageList(_ images: [Unsplash.Image]) -> some View {
    LazyVStack(spacing: 10) {
      ForEach(images) { image in
        Button {
          store.send(.navigate(.imageDetail(image)))
        } label: {
          ImageItemView(image)
            .containerRelativeFrame([.horizontal]) { length, _ in
              let insets = layoutEnvironment.contentInsets(.horizontal)
              return length - insets.leading - insets.trailing
            }
            .aspectRatio(CGSize(width: image.width, height: image.height), contentMode: .fit)
        }
      }
    }
  }
}

// MARK: - HomeView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  NavigationStack {
    HomeView(store: Store(initialState: HomeFeature.State()) {
      HomeFeature()
    } withDependencies: {
      $0.unsplash = .preview()
    })
  }
}

#endif
