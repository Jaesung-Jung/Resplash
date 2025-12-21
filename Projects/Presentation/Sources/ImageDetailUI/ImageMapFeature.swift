//
//  ImageMapFeature.swift
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

@Reducer
public struct ImageMapFeature {
  @ObservableState
  public struct State: Equatable {
    public let camera: MapCamera
    public let imageURL: URL
    public let label: String?
    public let coordinate: CLLocationCoordinate2D

    public init(camera: MapCamera, imageURL: URL, label: String?, coordinate: CLLocationCoordinate2D) {
      self.camera = camera
      self.imageURL = imageURL
      self.label = label
      self.coordinate = coordinate
    }

    public static func == (lhs: Self, rhs: Self) -> Bool { true }
  }

  public enum Action {
    case close
    case delegate(DelegateAction)
  }

  public enum DelegateAction {
    case updateCamera(MapCamera)
  }

  @Dependency(\.dismiss) var dismiss

  public init() {
  }

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .close:
        return .run { [dismiss] _ in await dismiss() }
      default:
        return .none
      }
    }
  }
}
