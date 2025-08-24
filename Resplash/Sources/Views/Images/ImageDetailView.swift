//
//  ImageDetailView.swift
//  Resplash
//
//  Created by 정재성 on 8/24/25.
//

import SwiftUI
import MapKit
import ComposableArchitecture

struct ImageDetailView: View {
  let store: StoreOf<ImageDetailFeature>

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 8) {
          ProfileView(store.state.image.user)

          RemoteImage(store.state.image.url.hd) {
            $0.resizable()
              .aspectRatio(CGSize(width: 1, height: CGFloat(store.state.image.height) / CGFloat(store.state.image.width)), contentMode: .fit)
          }
          .cornerRadius(4)

          if let description = store.state.image.description {
            Text(description)
          }
        }

        if let detail = store.state.detail {
          imageInfo(detail)
        }

        if let tags = store.state.detail?.tags {
          tagGrid(tags)
        }
      }
      .padding(.horizontal, 20)

      LazyVStack(spacing: 20) {
        if let images = store.state.seriesImages, !images.isEmpty {
          seriesImages(images)
        }

        if let images = store.state.relatedImages, !images.isEmpty {
          relatedImages(images)
        }

        if store.state.hasNextPage {
          ProgressView()
            .foregroundStyle(.tertiary)
            .progressViewStyle(.app.circleScale())
            .onAppear {
              store.send(.fetchNextRelatedImages)
            }
        }
      }
      .padding(.top, 20)
    }
    .navigationTitle(store.state.image.description ?? "Image")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(verbatim: "")
      }
    }
    .task {
      store.send(.fetchDetail)
    }
  }

  @ViewBuilder func imageInfo(_ detail: ImageAssetDetail) -> some View {
    VStack(spacing: 16) {
      Grid(alignment: .topLeading, horizontalSpacing: 20, verticalSpacing: 8) {
        GridRow {
          Text("Views")
          Text("Downloads")
          Text("Featured in")
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

      if let position = detail.location?.position {
        let coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
        let camera = MapCamera(centerCoordinate: coordinate, distance: 500)
        Map(initialPosition: .camera(camera)) {
          Annotation(coordinate: coordinate) {
            Circle()
              .fill(.white)
              .frame(width: 40, height: 40)
              .shadow(color: .black.opacity(0.75), radius: 8, x: 0, y: 2)
              .overlay {
                RemoteImage(detail.image.url.s3) {
                  $0.resizable()
                }
                .clipShape(Circle())
                .padding(2)
              }
          } label: {
          }
        }
        .aspectRatio(1.75, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 4))
      }
    }
  }

  @ViewBuilder func tagGrid(_ tags: [ImageAssetDetail.Tag]) -> some View {
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

  @ViewBuilder func seriesImages(_ images: [ImageAsset]) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("From this series")
        .font(.title2)
        .fontWeight(.bold)
        .padding(.horizontal, 20)

      ScrollView(.horizontal) {
        LazyHStack(spacing: 2) {
          ForEach(images) { image in
            Button {
              store.send(.navigateToImageDetail(image))
            } label: {
              ImageAssetView(image, size: .compact)
                .aspectRatio(CGSize(width: CGFloat(image.width) / CGFloat(image.height), height: 1), contentMode: .fit)
                .cornerRadius(2)
            }
          }
        }
        .frame(height: 150)
        .padding(.horizontal, 20)
      }
    }
    .scrollIndicators(.hidden)
  }

  @ViewBuilder func relatedImages(_ images: [ImageAsset]) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Related Images")
        .font(.title2)
        .fontWeight(.bold)

      MansonryGrid(images, columns: 2, spacing: 2) { image in
        Button {
          store.send(.navigateToImageDetail(image))
        } label: {
          ImageAssetView(image, size: .compact)
        }
      } size: {
        CGSize(width: $0.width, height: $0.height)
      }
    }
    .padding(.horizontal, 20)
  }
}

// MARK: - ImageDetailView Preview

#Preview {
  NavigationStack {
    ImageDetailView(
      store: Store(initialState: ImageDetailFeature.State(image: .preview)) {
        ImageDetailFeature()
      }
    )
  }
}
