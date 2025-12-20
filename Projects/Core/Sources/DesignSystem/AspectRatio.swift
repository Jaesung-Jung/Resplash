//
//  AspectRatio.swift
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

public struct AspectRatio<Content: View>: View {
  let content: Content
  let aspectRatio: CGFloat

  public init(_ aspectRatio: CGFloat, @ViewBuilder content: () -> Content) {
    self.aspectRatio = aspectRatio
    self.content = content()
  }

  public var body: some View {
    AspectRatioContainer(aspectRatio: aspectRatio) {
      content
    }
  }
}

// MARK: - AspectRatio.AspectRatioContainer

extension AspectRatio {
  struct AspectRatioContainer: Layout {
    let aspectRatio: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
      guard let item = subviews.first else {
        return .zero
      }
      let itemSize = item.sizeThatFits(.unspecified)
      let height = max(itemSize.height, itemSize.width / aspectRatio)
      let width = aspectRatio * height
      return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
      guard let item = subviews.first else {
        return
      }
      item.place(
        at: CGPoint(x: bounds.midX, y: bounds.midY),
        anchor: .center,
        proposal: ProposedViewSize(bounds.size)
      )
    }
  }
}

// MARK: - AspectRatio Preview

#if DEBUG

#Preview {
  AspectRatio(1) {
    Image(systemName: "apple.logo")
  }
}

#endif
