//
//  CollectionTitleView.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

import UIKit

final class CollectionTitleView: UICollectionReusableView {
  private let titleLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .title2).withWeight(.heavy)
  }

  @inlinable var title: String? {
    get { titleLabel.text }
    set { titleLabel.text = newValue }
  }

  override var intrinsicContentSize: CGSize {
    titleLabel.intrinsicContentSize
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    titleLabel.frame = bounds
  }

  override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    titleLabel.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
  }
}

// MARK: - CollectionTitleView Preview

#Preview {
  CollectionTitleView().then {
    $0.title = "Collection Title View"
  }
}
