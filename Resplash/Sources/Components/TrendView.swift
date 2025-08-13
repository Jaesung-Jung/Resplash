//
//  TrendKeywordView.swift
//  Resplash
//
//  Created by 정재성 on 8/13/25.
//

import SwiftUI

struct TrendKeywordView: View {
  let keyword: Trend.Keyword

  init(_ keyword: Trend.Keyword) {
    self.keyword = keyword
  }

  var body: some View {
    HStack(spacing: 8) {
      IconLabel(spacing: 12) {
        RemoteImage(keyword.thumbnailURL.sd) {
          $0.resizable()
            .aspectRatio(1, contentMode: .fill)
        }
        .clipShape(Circle())
      } content: {
        Text(keyword.title)
          .font(.title2)
          .fontWeight(.heavy)
          .lineLimit(1)
          .padding(.vertical, 12)
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
