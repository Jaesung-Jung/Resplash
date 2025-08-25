//
//  TrendKeywordView.swift
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

struct TrendKeywordView: View {
  let keyword: Trend.Keyword

  init(_ keyword: Trend.Keyword) {
    self.keyword = keyword
  }

  var body: some View {
    HStack(spacing: 8) {
      IconLabel(spacing: 12) {
        Circle()
          .fill(.clear)
          .aspectRatio(1, contentMode: .fit)
          .background {
            RemoteImage(keyword.thumbnailURL.sd) {
              $0.resizable()
                .aspectRatio(contentMode: .fill)
            }
            .clipShape(Circle())
          }
      } content: {
        Text(keyword.title)
          .font(.title2)
          .fontWeight(.heavy)
          .lineLimit(1)
          .padding(.vertical, 4)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      GrowthView(keyword.growth)
    }
  }
}

// MARK: - TrendKeywordView.GrowthView

extension TrendKeywordView {
  struct GrowthView: View {
    let growth: Growth
    let value: Int

    init(_ growth: Int) {
      self.growth = Growth(growth)
      self.value = growth
    }

    var body: some View {
      HStack(spacing: 4) {
        switch growth {
        case .up:
          Text("\(value.formatted(.number))%")
          Image(systemName: "arrow.turn.right.up")
        case .down:
          Text("\(value.formatted(.number))%")
          Image(systemName: "arrow.turn.right.down")
        case .stedy:
          Image(systemName: "minus")
        }
      }
      .font(.subheadline)
      .fontWeight(.semibold)
      .foregroundStyle(foreground(for: growth))
    }

    func foreground(for growth: Growth) -> some ShapeStyle {
      switch growth {
      case .up:
        Color.green
      case .down:
        Color.red
      case .stedy:
        Color.gray
      }
    }
  }
}

// MARK: - TrendKeywordView.Growth

extension TrendKeywordView {
  enum Growth {
    case up
    case down
    case stedy

    init(_ growth: Int) {
      if growth > 0 {
        self = .up
      } else if growth < 0 {
        self = .down
      } else {
        self = .stedy
      }
    }
  }
}

// MARK: - TrendView Preview

#if DEBUG

#Preview {
  TrendKeywordView(Trend.preview.keywords[0])
    .padding(.horizontal, 20)
}

#endif
