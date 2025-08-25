//
//  HFlow.swift
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

struct HFlow: Layout {
  let itemSpacing: CGFloat
  let lineSpacing: CGFloat

  struct Cache {
    var sizes: [CGSize] = []
  }

  func makeCache(subviews: Subviews) -> Cache {
    Cache(sizes: subviews.map { $0.sizeThatFits(.unspecified) })
  }

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
    var contentSize = CGSize.zero
    var lineWidth: CGFloat = .zero
    var lineHeight: CGFloat = .zero

    let proposalWidth = proposal.width ?? .infinity
    for index in subviews.indices {
      let itemSize = cache.sizes[index]
      if lineWidth + itemSize.width > proposalWidth {
        lineWidth = itemSize.width
        lineHeight = itemSize.height
        contentSize.height += lineHeight + lineSpacing
      } else {
        lineWidth += itemSize.width + itemSpacing
        lineHeight = max(lineHeight, itemSize.height)
      }
      contentSize.width = max(contentSize.width, lineWidth)
    }
    contentSize.height += lineHeight
    return contentSize
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
    var xPosition: CGFloat = .zero
    var yPosition: CGFloat = .zero
    var lineHeight: CGFloat = .zero
    let proposalWidth = proposal.width ?? .infinity
    for index in subviews.indices {
      let itemSize = cache.sizes[index]
      if (xPosition + itemSize.width) > proposalWidth {
        xPosition = .zero
        yPosition += lineHeight + lineSpacing
        lineHeight = .zero
      }
      subviews[index].place(
        at: CGPoint(
          x: bounds.minX + xPosition + itemSize.width * 0.5,
          y: bounds.minY + yPosition + itemSize.height * 0.5
        ),
        anchor: .center,
        proposal: ProposedViewSize(cache.sizes[index])
      )

      xPosition += itemSize.width + itemSpacing
      lineHeight = max(lineHeight, itemSize.height)
    }
  }
}

// MARK: - HFlow Preview

#if DEBUG

#Preview {
  @Previewable @State var items = (1...20).map { "Item \($0)" }
  HFlow(itemSpacing: 8, lineSpacing: 8) {
    ForEach(items, id: \.self) {
      Text($0)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.quinary)
        .cornerRadius(4)
    }
  }
  .padding(.horizontal, 20)
}

#endif
