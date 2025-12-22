//
//  MapView.swift
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
import ResplashDesignSystem

public struct MapView: View {
  let interactionModes: MapInteractionModes
  let coordinate: CLLocationCoordinate2D
  let thumbnailURL: URL
  let label: String

  public init(interactionModes: MapInteractionModes = .all, coordinate: CLLocationCoordinate2D, thumbnailURL: URL, label: String) {
    self.interactionModes = interactionModes
    self.coordinate = coordinate
    self.thumbnailURL = thumbnailURL
    self.label = label
  }

  public var body: some View {
    let camera = MapCamera(centerCoordinate: coordinate, distance: 3000)
    Map(initialPosition: .camera(camera), interactionModes: interactionModes) {
      Annotation(coordinate: coordinate) {
        Circle()
          .fill(.white)
          .frame(width: 40, height: 40)
          .shadow(color: .black.opacity(0.75), radius: 8, x: 0, y: 2)
          .overlay {
            RemoteImage(thumbnailURL) {
              $0.resizable()
            }
            .clipShape(Circle())
            .padding(2)
          }
      } label: {
        Text(label)
      }
    }
  }
}

// MARK: - MapView Preview

#if DEBUG

#Preview {
  MapView(
    coordinate: CLLocationCoordinate2D(
      latitude: 37.334697869923474,
      longitude: -122.00897534599764
    ),
    thumbnailURL: URL(string: "https://lh3.googleusercontent.com/p/AF1QipPKiW7H_S9QZh3gSJYdZeM7dmtyRjWCc6wtcKrx=w426-h240-k-no")!,
    label: "Apple Park"
  )
}

#endif
