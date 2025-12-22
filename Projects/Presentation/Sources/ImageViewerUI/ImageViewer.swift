//
//  ImageViewer.swift
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
import ResplashEntities
import ResplashDesignSystem

public struct ImageViewer: View {
  let store: StoreOf<ImageViewerFeature>

  public init(store: StoreOf<ImageViewerFeature>) {
    self.store = store
  }

  public var body: some View {
    RemoteImage(store.image.url.hd) {
      $0.resizable()
        .aspectRatio(CGSize(width: 1, height: store.image.height / store.image.width), contentMode: .fit)
    }
    .navigationTransition(.zoom(sourceID: store.image.id, in: store.namespace))
  }
}

// MARK: - ImageViewer Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  @Previewable @Namespace var namespace
  NavigationStack {
    let state = ImageViewerFeature.State(
      image: .preview1,
      previewURL: Unsplash.Image.preview1.url.hd,
      namespace: namespace
    )
    ImageViewer(store: Store(initialState: state) {
      ImageViewerFeature()
    } withDependencies: {
      $0.unsplash = .preview()
    })
  }
}

#endif
