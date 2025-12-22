//
//  ImageCollectionView.swift
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

public struct ImageCollectionView: View {
  @Environment(\.displayScale) var displayScale
  let collection: Unsplash.ImageCollection

  public init(_ collection: Unsplash.ImageCollection) {
    self.collection = collection
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      UserView(collection.user)
        .size(.compact)

      Rectangle()
        .fill(.background)
        .aspectRatio(CGSize(width: 1, height: 0.75), contentMode: .fit)
        .overlay {
          HStack(spacing: 2) {
            image(collection.imageURLs[safe: 0]?.low)
            VStack(spacing: 2) {
              image(collection.imageURLs[safe: 1]?.low)
              image(collection.imageURLs[safe: 2]?.low)
            }
          }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(.secondary, lineWidth: 1 / displayScale)
        }

      VStack(alignment: .leading, spacing: 4) {
        Text(collection.title)
          .font(.body)
          .fontWeight(.heavy)
        Text("\(collection.totalImages) image")
          .font(.footnote)
          .fontWeight(.semibold)
          .foregroundStyle(.secondary)
      }
    }
    .lineLimit(1)
  }

  @ViewBuilder func image(_ url: URL?) -> some View {
    Rectangle()
      .fill(.quinary)
      .background {
        RemoteImage(url) {
          $0.resizable().aspectRatio(contentMode: .fill)
        }
      }
      .clipShape(Rectangle())
      .contentShape(Rectangle())
  }
}

// MARK: - ImageCollectionView Preview

#if DEBUG

#Preview {
  ImageCollectionView(.preview)
    .padding(.horizontal, 20)
}

#endif
