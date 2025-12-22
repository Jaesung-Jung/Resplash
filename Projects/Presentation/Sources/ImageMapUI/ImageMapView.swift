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
import ResplashUI
import ResplashDesignSystem

public struct ImageMapView: View {
  let store: StoreOf<ImageMapFeature>

  public init(store: StoreOf<ImageMapFeature>) {
    self.store = store
  }

  public var body: some View {
    if let location = store.image.location, let position = location.position {
      MapView(
        coordinate: CLLocationCoordinate2D(
          latitude: position.latitude,
          longitude: position.longitude
        ),
        thumbnailURL: store.image.url.s3,
        label: location.name
      )
    }
  }
}

// MARK: - ImageMapView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  NavigationStack {
    ImageMapView(store: Store(initialState: ImageMapFeature.State(image: .preview1)) {
      ImageMapFeature()
    } withDependencies: {
      $0.unsplash = .preview()
    })
  }
}

#endif
