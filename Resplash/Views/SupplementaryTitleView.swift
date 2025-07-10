//
//  SupplementaryTitleView.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

import UIKit

final class SupplementaryTitleView: UICollectionReusableView {
  private let titleLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .title2).withWeight(.heavy)
  }

  private let button = UIButton(configuration: .plain()).then {
    $0.configuration?.imagePadding = 4
    $0.configuration?.imagePlacement = .trailing
    $0.configuration?.cornerStyle = .capsule
    $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
  }

  private let titleSpacing: CGFloat = 8

  @inlinable var title: String? {
    get { titleLabel.text }
    set {
      titleLabel.text = newValue
      invalidateIntrinsicContentSize()
    }
  }

  var action: UIAction? {
    didSet {
      if let oldValue {
        button.removeAction(oldValue, for: .primaryActionTriggered)
      }
      if let action {
        button.addAction(action, for: .primaryActionTriggered)
      }
      button.configuration?.title = action?.title
      button.configuration?.attributedTitle = action.map(\.title).map {
        var attributedString = AttributedString($0)
        attributedString.font = .preferredFont(forTextStyle: .headline).withWeight(.bold)
        return attributedString
      }
      button.configuration?.image = action.flatMap(\.image).map {
        $0.withConfiguration(
          UIImage.SymbolConfiguration(textStyle: .footnote)
            .applying(UIImage.SymbolConfiguration(weight: .bold))
        )
      }
      button.isHidden = action == nil
      invalidateIntrinsicContentSize()
    }
  }

  override var intrinsicContentSize: CGSize {
    let titleSize = titleLabel.intrinsicContentSize
    let buttonSize = button.isHidden ? .zero : button.intrinsicContentSize
    return CGSize(
      width: titleSize.width + titleSpacing + buttonSize.width,
      height: max(titleSize.height, buttonSize.height)
    )
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(titleLabel)
    addSubview(button)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let spacing = button.isHidden ? 0 : titleSpacing
    let buttonSize = button.isHidden ? .zero : button.intrinsicContentSize
    button.frame = CGRect(
      x: bounds.maxX - buttonSize.width,
      y: bounds.minY,
      width: buttonSize.width,
      height: bounds.height
    )
    titleLabel.frame = CGRect(
      x: bounds.minX,
      y: bounds.minY,
      width: bounds.width - spacing - buttonSize.width,
      height: bounds.height
    )
  }

  override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    let contentSize = intrinsicContentSize
    return CGSize(
      width: min(targetSize.width, contentSize.width),
      height: min(targetSize.height, contentSize.height)
    )
  }
}

// MARK: - SupplementaryTitleView Preview

#Preview {
  SupplementaryTitleView().then {
    $0.title = "SupplementaryTitleView"
    $0.action = UIAction(title: "More", image: UIImage(systemName: "chevron.right")) { _ in }
  }
}
