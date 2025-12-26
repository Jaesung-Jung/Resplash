//
//  ImageCollectionHGrid.swift
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
import ResplashEntities
import ResplashDesignSystem

public struct ImageCollectionHGrid: View {
  let collections: [Unsplash.ImageCollection]
  let spacing: CGFloat
  let insets: EdgeInsets
  let action: @MainActor (Unsplash.ImageCollection) -> Void

  public init(_ collections: [Unsplash.ImageCollection], spacing: CGFloat = 10, insets: EdgeInsets? = nil, action: @MainActor @escaping (Unsplash.ImageCollection) -> Void) {
    self.collections = collections
    self.spacing = spacing
    self.insets = insets ?? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    self.action = action
  }

  public var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHGrid(rows: [GridItem()], alignment: .top, spacing: spacing) {
        ForEach(collections) { collection in
          Button {
            action(collection)
          } label: {
            ImageCollectionView(collection)
              .containerRelativeFrame(.horizontal) { length, _ in (length - insets.leading) / 1.5 }
          }
        }
      }
      .padding(insets)
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned(limitBehavior: .never, anchor: .leading))
  }
}

// MARK: - ImageCollectionHGrid Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  ImageCollectionHGrid([.preview1, .preview2], insets: EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)) { _ in
  }
  .buttonStyle(.ds.plain())
}

#endif
