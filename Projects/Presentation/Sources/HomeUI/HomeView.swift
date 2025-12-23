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

  let store: StoreOf<HomeFeature>

  public init(store: StoreOf<HomeFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      LazyVStack(spacing: 40, pinnedViews: [.sectionHeaders]) {
        Section {
          if let collections = store.collections {
            VStack(alignment: .leading) {
              Button {
                store.send(.navigate(.collections))
              } label: {
                sectionTitle(.localizable(.imageCollections), showsDisclosureIndicator: true)
              }
              .padding(layoutEnvironment.contentInsets(.horizontal))
              .buttonStyle(.ds.plain())

              collectionList(collections)
            }
          }

          if let images = store.images {
            VStack(alignment: .leading) {
              sectionTitle(.localizable(.featured))
                .padding(layoutEnvironment.contentInsets(.horizontal))

              imageList(images)
            }
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
      mediaPickerMenu()
    }
    .task {
      store.send(.fetchContents)
    }
  }
}

// MARK: - HomeView (ViewBuilders)

extension HomeView {
  @ViewBuilder func mediaPickerMenu() -> some View {
    Menu {
      Section(.localizable(.media)) {
        ForEach(Unsplash.MediaType.allCases, id: \.self) { mediaType in
          Button {
            store.send(.selectMediaType(mediaType))
          } label: {
            HStack {
              if store.mediaType == mediaType {
                Image(systemName: "checkmark")
              }
              Text(localizedString(mediaType))
            }
          }
        }
      }
    } label: {
      HStack {
        let systemName = switch store.mediaType {
        case .photo:
          "photo.on.rectangle.angled"
        case .illustration:
          "pencil.and.scribble"
        }
        Image(systemName: systemName)
        Text(localizedString(store.mediaType))
      }
    }
  }

  @ViewBuilder func sectionTitle(_ key: LocalizedStringKey, showsDisclosureIndicator: Bool = false) -> some View {
    LabeledContent {
      if showsDisclosureIndicator {
        Image(systemName: "chevron.right")
          .foregroundStyle(.secondary)
      }
    } label: {
      Text(key)
        .font(.title2)
    }
    .fontWeight(.bold)
    .foregroundStyle(.primary)
  }

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
            .buttonStyle(.plain)
          }
        }
        .padding(layoutEnvironment.contentInsets([.top, .horizontal]))
      }
    }
    .scrollClipDisabled()
  }

  @ViewBuilder func collectionList(_ collections: [Unsplash.ImageCollection]) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHGrid(rows: [GridItem()], alignment: .top, spacing: 10) {
        ForEach(collections) { collection in
          Button {
            store.send(.navigate(.collectionImages(collection)))
          } label: {
            ImageCollectionView(collection)
              .containerRelativeFrame(.horizontal) { length, _ in (length - 20) / 1.5 }
          }
          .buttonStyle(.ds.plain())
        }
      }
      .padding(layoutEnvironment.contentInsets(.horizontal))

      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned(limitBehavior: .never, anchor: .leading))
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
        .buttonStyle(.ds.plain())
      }
    }
  }
}

// MARK: - HomeView (Strings)

extension HomeView {
  @inlinable
  func localizedString(_ mediaType: Unsplash.MediaType) -> LocalizedStringKey {
    switch mediaType {
    case .photo:
      return .localizable(.photo)
    case .illustration:
      return .localizable(.illustration)
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
