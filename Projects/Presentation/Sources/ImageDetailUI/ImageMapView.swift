//
//  ImageMapView.swift
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
import ResplashEntities
import ResplashDesignSystem

public struct ImageMapView: View {
  let store: StoreOf<ImageMapFeature>

  public init(store: StoreOf<ImageMapFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      MapView(
        camera: store.camera,
        imageURL: store.imageURL,
        label: store.label,
        coordinate: store.coordinate
      )
      .onMapCameraChange { ctx in
        print("[2] rect: \(ctx.rect), region: \(ctx.region)")
      }
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            store.send(.close)
          } label: {
            Image(systemName: "xmark")
          }
        }
      }
    }
  }
}

// MARK: - ImageMapView.MapView

extension ImageMapView {
  public struct MapView: View {
    let camera: MapCamera
    let imageURL: URL
    let label: String?
    let coordinate: CLLocationCoordinate2D

    public init(camera: MapCamera, imageURL: URL, label: String?, coordinate: CLLocationCoordinate2D) {
      self.camera = camera
      self.imageURL = imageURL
      self.label = label
      self.coordinate = coordinate
    }

    public var body: some View {
      Map(initialPosition: .camera(camera)) {
        Annotation(coordinate: coordinate) {
          Circle()
            .fill(.white)
            .frame(width: 40, height: 40)
            .shadow(color: .black.opacity(0.75), radius: 8, x: 0, y: 2)
            .overlay {
              RemoteImage(imageURL) {
                $0.resizable()
              }
              .clipShape(Circle())
              .padding(2)
            }
        } label: {
          if let label {
            Text(label)
          }
        }
      }
    }
  }
}

// MARK: - ImageMapView Preview

#if DEBUG

import ResplashPreviewSupports

//#Preview {
//  if let state = ImageMapFeature.State(assetDetail: .preview1) {
//    ImageMapView(store: Store(initialState: state) {
//      ImageMapFeature()
//    })
//  } else {
//    Text("No Location")
//  }
//}

#endif
