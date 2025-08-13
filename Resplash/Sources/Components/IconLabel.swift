//
//  IconLabel.swift
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

struct IconLabel<Icon: View, Content: View>: View {
  let spacing: CGFloat
  let icon: Icon
  let content: Content

  init(spacing: CGFloat, @ViewBuilder icon: () -> Icon, @ViewBuilder content: () -> Content) {
    self.spacing = spacing
    self.icon = icon()
    self.content = content()
  }

  var body: some View {
    IconLabelLayout(spacing: spacing) {
      icon.aspectRatio(contentMode: .fit)
      content
    }
  }
}

// MARK: - IconLabel<Image, Text>

extension IconLabel where Icon == Image, Content == Text {
  init(spacing: CGFloat, icon: Image, text: Text) {
    self.init(spacing: spacing, icon: { icon.resizable() }, content: { text })
  }

  init(spacing: CGFloat, systemImage: String, text: LocalizedStringKey) {
    self.init(spacing: spacing, icon: { Image(systemName: systemImage).resizable() }, content: { Text(text) })
  }
}

// MARK: - IconLabel.IconLabelLayout

extension IconLabel {
  private struct IconLabelLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
      guard let icon = subviews[safe: 0], let label = subviews[safe: 1] else {
        return .zero
      }
      let intrinsicIconSize = icon.sizeThatFits(.unspecified)
      let intrinsicLabelSize = label.sizeThatFits(.unspecified)

      let ratio = if intrinsicIconSize.height > 0 { intrinsicLabelSize.height / intrinsicIconSize.height } else { CGFloat(0) }
      let iconSize = CGSize(
        width: intrinsicIconSize.width * ratio,
        height: intrinsicIconSize.height * ratio
      )

      let labelSize = label.sizeThatFits(
        ProposedViewSize(
          width: proposal.width.map { max(0, $0 - iconSize.width - spacing) },
          height: proposal.height
        )
      )
      cache.iconSize = iconSize
      cache.labelSize = labelSize

      return CGSize(
        width: iconSize.width + spacing + labelSize.width,
        height: max(iconSize.height, labelSize.height)
      )
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
      guard let icon = subviews[safe: 0], let label = subviews[safe: 1] else {
        return
      }
      let iconSize = cache.iconSize ?? .zero
      icon.place(
        at: CGPoint(x: bounds.minX, y: bounds.minY),
        anchor: .topLeading,
        proposal: ProposedViewSize(iconSize)
      )

      let labelSize = cache.labelSize ?? .zero
      label.place(
        at: CGPoint(x: bounds.minX + iconSize.width + spacing, y: bounds.minY),
        anchor: .topLeading,
        proposal: ProposedViewSize(labelSize)
      )
    }

    func makeCache(subviews: Subviews) -> Cache { Cache() }

    struct Cache {
      var iconSize: CGSize?
      var labelSize: CGSize?
    }
  }
}

// MARK: - IconLabel Preview

#Preview {
  IconLabel(spacing: 8, systemImage: "swift", text: "Swift")
    .font(.title)
    .fontWeight(.bold)
}
