//
//  CategoryItemView.swift
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

public struct CategoryItemView: View {
  let item: Unsplash.Category.Item

  public init(_ item: Unsplash.Category.Item) {
    self.item = item
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Rectangle()
        .fill(.clear)
        .aspectRatio(CGSize(width: 1, height: 0.625), contentMode: .fit)
        .background {
          RemoteImage(item.coverImageURL.sd) {
            $0.resizable()
              .aspectRatio(contentMode: .fill)
          }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))

      VStack(alignment: .leading, spacing: 4) {
        Text(item.title)
          .font(.body)
          .fontWeight(.bold)

        Text("\(item.imageCount.formatted(.number))+ images")
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(.secondary)
      }
      .lineLimit(1)
    }
    .contentShape(Rectangle())
  }
}

// MARK: - CategoryView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  CategoryItemView(.preview)
    .frame(width: 300)
}

#endif
