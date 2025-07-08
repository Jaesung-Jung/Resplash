//
//  LikeView.swift
//  Resplash
//
//  Created by 정재성 on 7/8/25.
//

import UIKit
import SnapKit

final class LikeView: UIView {
  private let imageView = UIImageView().then {
    $0.image = UIImage(
      systemName: "heart.fill",
      withConfiguration: UIImage.SymbolConfiguration(
        font: .preferredFont(forTextStyle: .footnote)
      )
    )
    $0.contentMode = .scaleAspectFit
    $0.tintColor = .systemRed
  }

  private let textLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .subheadline).withWeight(.semibold)
  }

  private let imageSpacing: CGFloat = 4

  override var intrinsicContentSize: CGSize {
    let imageSize = imageView.intrinsicContentSize
    let textSize = textLabel.intrinsicContentSize
    return CGSize(
      width: imageSize.width + imageSpacing + textSize.width,
      height: max(imageSize.height, textSize.height)
    )
  }

  @inlinable var count: Int? {
    get { textLabel.text.flatMap { Int($0) } }
    set {
      textLabel.text = newValue?.formatted(.number)
      invalidateIntrinsicContentSize()
    }
  }

  @inlinable var textColor: UIColor! {
    get { textLabel.textColor }
    set { textLabel.textColor = newValue }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(imageView)
    addSubview(textLabel)
    registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _) in
      self.invalidateIntrinsicContentSize()
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let imageSize = imageView.intrinsicContentSize
    imageView.frame = CGRect(
      x: bounds.minX,
      y: bounds.midY - imageSize.height * 0.5,
      width: imageSize.width,
      height: imageSize.height
    )
    textLabel.frame = CGRect(
      x: imageView.frame.maxX + imageSpacing,
      y: bounds.minY,
      width: bounds.width - imageView.frame.maxX - imageSpacing,
      height: bounds.height
    )
  }
}

// MARK: - LikeView Preview

#Preview {
  LikeView().then {
    $0.count = 9999
  }
}
