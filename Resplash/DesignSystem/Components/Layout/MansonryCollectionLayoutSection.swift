//
//  MansonryCollectionLayoutSection.swift
//  Resplash
//
//  Created by 정재성 on 7/10/25.
//

import UIKit

final class MansonryCollectionLayoutSection: NSCollectionLayoutSection {
  convenience init(columns: Int, contentInsets: NSDirectionalEdgeInsets, spacing: CGFloat, environment: NSCollectionLayoutEnvironment, sizes: [CGSize]) {
    let containerSize = CGSize(
      width: environment.container.effectiveContentSize.width - contentInsets.leading - contentInsets.trailing,
      height: environment.container.effectiveContentSize.height - contentInsets.top - contentInsets.bottom
    )

    let itemWidth = (containerSize.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
    var columnHeights = Array(repeating: CGFloat(0), count: columns)
    let columnX = (0..<columns).map { CGFloat($0) * (itemWidth + spacing) }

    var layoutItems: [NSCollectionLayoutGroupCustomItem] = []
    layoutItems.reserveCapacity(sizes.count)

    for size in sizes {
      let itemHeight = itemWidth * (size.height / size.width)
      let minColumnIndex = columnHeights.enumerated().min(by: { $0.element < $1.element })!.offset
      let x = columnX[minColumnIndex]
      let y = columnHeights[minColumnIndex]
      let layoutItem = NSCollectionLayoutGroupCustomItem(
        frame: CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
      )
      layoutItems.append(layoutItem)
      columnHeights[minColumnIndex] = y + itemHeight + spacing
    }

    let layoutSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .absolute(columnHeights.max() ?? 0)
    )
    let group = NSCollectionLayoutGroup.custom(layoutSize: layoutSize) { _ in layoutItems }
    self.init(group: group)
    self.interGroupSpacing = spacing
    self.contentInsets = contentInsets
  }
}
