//
//  ImageDetailView.swift
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
import MapKit
import ComposableArchitecture
import ResplashUI
import ResplashEntities
import ResplashStrings
import ResplashDesignSystem

public struct ImageDetailView: View {
  @Environment(\.layoutEnvironment) var layoutEnvironment
  @Namespace var namespace

  @Bindable var store: StoreOf<ImageDetailFeature>

  public init(store: StoreOf<ImageDetailFeature>) {
    self.store = store
  }

  public var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 20) {
        UserView(store.image.user)

        VStack(alignment: .leading, spacing: 8) {
          Button {
            store.send(.navigate(.imageViewer(store.image, store.image.url.hd, namespace)))
          } label: {
            RemoteImage(store.image.url.hd) {
              $0.resizable()
                .aspectRatio(CGSize(width: 1, height: store.image.height / store.image.width), contentMode: .fit)
            }
            .cornerRadius(4)
            .matchedTransitionSource(id: store.image.id, in: namespace)
          }

          if let description = store.image.description {
            Text(description)
          }
        }

        if let detail = store.detail {
          imageInfo(detail)
        }

        if let tags = store.detail?.tags {
          tagGrid(tags)
        }
      }
      .padding(layoutEnvironment.contentInsets(.horizontal))

      LazyVStack(spacing: 20) {
        if let images = store.seriesImages, !images.isEmpty {
          seriesImages(images)
        }

        if let images = store.relatedImages, !images.isEmpty {
          relatedImages(images)
        }

        if store.hasNextPage {
          ProgressView()
            .foregroundStyle(.tertiary)
            // .progressViewStyle(.circleScale)
            .onAppear {
              store.send(.fetchNextRelatedImages)
            }
        }
      }
      .padding(.top, 20)
    }
    .navigationTitle(store.image.description ?? .localizable(.image))
    .navigationBarTitleDisplayMode(.inline)
    .buttonStyle(.ds.plain())
    .task {
      store.send(.fetchImageDetail)
    }
  }
}

// MARK: - ImageDetailView (ViewBuilders)

extension ImageDetailView {
  @ViewBuilder func imageInfo(_ detail: Unsplash.ImageDetail) -> some View {
    VStack(spacing: 16) {
      Grid(alignment: .topLeading, horizontalSpacing: 20, verticalSpacing: 8) {
        GridRow {
          Text(.localizable(.hitCount))
          Text(.localizable(.downloadCount))
          Text(.localizable(.featuredIn))
        }
        .font(.footnote)
        .fontWeight(.medium)
        .foregroundStyle(.secondary)

        GridRow {
          Text(detail.views.formatted(.number))
          Text(detail.downloads.formatted(.number))
          HStack {
            Text((["\(detail.type)"] + detail.topics.map(\.title)).joined(separator: ", "))
            Spacer(minLength: 0)
          }
        }
        .font(.subheadline)
        .fontWeight(.semibold)
      }

      Divider()

      Grid(alignment: .topLeading, horizontalSpacing: 8, verticalSpacing: 8) {
        GridRow {
          Image(systemName: "calendar")
          Text("Published on \(detail.createdAt.formatted(date: .abbreviated, time: .omitted))")
          Spacer(minLength: 0)
        }
        GridRow {
          Image(systemName: "heart.fill")
          Text("\(detail.likes.formatted(.number)) likes")
        }
        if let exif = detail.exif?.name {
          GridRow {
            Image(systemName: "camera")
            Text(exif)
          }
        }
        if let location = detail.location {
          GridRow {
            Image(systemName: "location")
            Text(location.name)
          }
        }
      }
      .font(.subheadline)
      .fontWeight(.medium)
      .foregroundStyle(.secondary)

      if let location = detail.location, let position = location.position {
        Button {
          store.send(.navigate(.imageMap(detail)))
        } label: {
          ZStack {
            MapView(
              coordinate: CLLocationCoordinate2D(
                latitude: position.latitude,
                longitude: position.longitude
              ),
              thumbnailURL: detail.image.url.s3,
              label: location.name
            )
            .allowsHitTesting(false)

            Rectangle()
              .fill(.clear)
              .contentShape(Rectangle())
          }
          .aspectRatio(1.5, contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 4))
        }
      }
    }
  }

  @ViewBuilder func tagGrid(_ tags: [Unsplash.ImageDetail.Tag]) -> some View {
    HStack(spacing: 0) {
      HFlow(itemSpacing: 8, lineSpacing: 8) {
        ForEach(tags, id: \.title) {
          Text($0.title)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.quinary)
            .cornerRadius(4)
        }
      }
      Spacer(minLength: 0)
    }
  }

  @ViewBuilder func seriesImages(_ images: [Unsplash.Image]) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(.localizable(.fromThisSeries))
        .font(.title2)
        .fontWeight(.bold)
        .padding(layoutEnvironment.contentInsets(.horizontal))

      ScrollView(.horizontal) {
        LazyHStack(spacing: 2) {
          ForEach(images) { image in
            Button {
              store.send(.navigate(.imageDetail(image)))
            } label: {
              ImageItemView(image)
                .size(.compact)
                .aspectRatio(CGSize(width: image.width / image.height, height: 1), contentMode: .fit)
                .cornerRadius(2)
            }
          }
        }
        .frame(height: 150)
        .padding(layoutEnvironment.contentInsets(.horizontal))
      }
    }
    .scrollIndicators(.hidden)
  }

  @ViewBuilder func relatedImages(_ images: [Unsplash.Image]) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(.localizable(.relatedImages))
        .font(.title2)
        .fontWeight(.bold)

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
    }
    .padding(layoutEnvironment.contentInsets(.horizontal))
  }
}

// MARK: - ImageDetailView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  NavigationStack {
    ImageDetailView(store: Store(initialState: ImageDetailFeature.State(image: .preview1)) {
      ImageDetailFeature()
    } withDependencies: {
      $0.unsplash = .preview()
    })
  }
  .environment(\.locale, Locale(identifier: "ko_KR"))
}

#endif
