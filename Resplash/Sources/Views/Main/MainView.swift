//
//  MainView.swift
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

struct MainView: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.horizontalSizeClass) var hSizeClass
  let store: StoreOf<MainFeature>

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(spacing: 40, pinnedViews: [.sectionHeaders]) {
          Section {
            if let collections = store.state.collections {
              VStack(alignment: .leading) {
                NavigationLink {
                } label: {
                  HStack {
                    Text("Collections")
                      .fontWeight(.heavy)
                      .foregroundStyle(.primary)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                      .foregroundStyle(.secondary)
                  }
                  .font(.title2)
                  .tint(.primary)
                  .padding(.horizontal, 20)
                }

                imageCollectons(collections)
              }
            }

            if let images = store.state.images {
              VStack(alignment: .leading) {
                Text("Featured")
                  .font(.title2)
                  .fontWeight(.heavy)
                  .padding(.horizontal, 20)

                imageList(images)
              }
            }

            if store.state.hasNextPage {
              ProgressView()
                .progressViewStyle(.app.circleScale())
                .onAppear {
                  store.send(.fetchNextImages)
                }
            }
          } header: {
            if let topics = store.state.topics {
              topic(topics)
            }
          }
        }
      }
      .scrollEdgeEffectStyle(.soft, for: [.top, .bottom])
      .navigationTitle(store.state.mediaType.localizedStringResource)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Menu {
            Section("Media") {
              ForEach(MediaType.allCases, id: \.self) { mediaType in
                Button {
                  store.send(.selectMediaType(mediaType))
                } label: {
                  HStack {
                    if store.state.mediaType == mediaType {
                      Image(systemName: "checkmark")
                    }
                    Text(mediaType.localizedStringResource)
                  }
                }
              }
            }
          } label: {
            Image(systemName: "chevron.down")
          }
        }
      }
    }
    .task {
      store.send(.fetch)
    }
  }

  @ViewBuilder func topic(_ topics: [Topic]) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(spacing: 10) {
        GlassEffectContainer {
          ForEach(topics) {
            TopicView($0)
              .foregroundStyle(colorScheme == .dark ? .white : .primary)
              .glassEffect(
                .clear
                  .tint((colorScheme == .dark ? Color.black : .white).opacity(0.5))
                  .interactive()
              )
          }
        }
      }
      .padding(.vertical, 10)
      .padding(.horizontal, 20)
    }
  }

  @ViewBuilder func imageCollectons(_ collections: [ImageAssetCollection]) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHGrid(rows: [GridItem()], alignment: .top, spacing: 10) {
        ForEach(collections) {
          ImageCollectionView($0)
            .containerRelativeFrame(.horizontal) { length, _ in (length - 20) / 1.5 }
        }
      }
      .padding(.horizontal, 20)
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned(limitBehavior: .never, anchor: .leading))
  }

  @ViewBuilder func imageList(_ images: [ImageAsset]) -> some View {
    LazyVStack(spacing: 10) {
      ForEach(images) { image in
        ImageAssetView(image)
          .containerRelativeFrame([.horizontal]) { length, _ in length - 40 }
          .aspectRatio(CGSize(width: image.width, height: image.height), contentMode: .fit)
      }
    }
  }
}

// MARK: - MainView Preview

#if DEBUG

#Preview {
  MainView(
    store: Store(initialState: MainFeature.State()) {
      MainFeature()
    }
  )
}

#endif
