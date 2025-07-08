//
//  MiniProfileView.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

import UIKit
import Kingfisher

final class MiniProfileView: UIView {
  private let profileImageBackgroundView = UIView().then {
    $0.backgroundColor = .label
  }

  private let profileImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
  }

  private let nameLabel = UILabel().then {
    $0.textColor = .label
  }

  private let hireLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .caption1)
    $0.text = "Available for hire"
    $0.textColor = .secondaryLabel
  }

  private let imageSpacing: CGFloat = 8

  private let textSpacing: CGFloat = 2

  let size: Size

  override var intrinsicContentSize: CGSize {
    switch size {
    case .regular:
      let nameSize = nameLabel.intrinsicContentSize
      let hireSize = hireLabel.intrinsicContentSize
      let height = nameSize.height + textSpacing + hireSize.height
      let width = height + imageSpacing + max(nameSize.width, hireSize.width)
      return CGSize(width: width, height: height)
    case .small:
      let nameSize = nameLabel.intrinsicContentSize
      let height = max(30, nameSize.height)
      return CGSize(width: height + imageSpacing + nameSize.width, height: height)
    }
  }

  init(_ size: Size = .regular) {
    self.size = size
    super.init(frame: .zero)
    addSubview(profileImageBackgroundView)
    addSubview(profileImageView)
    addSubview(nameLabel)
    addSubview(hireLabel)
    registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _) in
      self.invalidateIntrinsicContentSize()
    }

    switch size {
    case .regular:
      nameLabel.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
    case .small:
      nameLabel.font = .preferredFont(forTextStyle: .subheadline).withWeight(.medium)
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    profileImageBackgroundView.frame = CGRect(
      x: bounds.minX,
      y: bounds.minY,
      width: bounds.height,
      height: bounds.height
    )
    profileImageView.frame = profileImageBackgroundView.frame.insetBy(dx: 1, dy: 1)

    profileImageBackgroundView.layer.cornerRadius = profileImageBackgroundView.bounds.height * 0.5
    profileImageView.layer.cornerRadius = profileImageView.bounds.height * 0.5

    let x = bounds.minX + profileImageBackgroundView.frame.width + imageSpacing
    if hireLabel.isHidden {
      nameLabel.frame = CGRect(
        x: x,
        y: bounds.minY,
        width: bounds.maxX - x,
        height: bounds.height
      )
    } else {
      nameLabel.frame = CGRect(
        x: x,
        y: bounds.minY,
        width: bounds.maxX - x,
        height: nameLabel.intrinsicContentSize.height
      )
      let size = hireLabel.intrinsicContentSize
      hireLabel.frame = CGRect(
        x: x,
        y: bounds.maxY - size.height,
        width: nameLabel.frame.width,
        height: size.height
      )
    }
  }

  func configure(_ user: User) {
    profileImageView.kf.setImage(with: user.imageURL.medium)
    nameLabel.text = user.name
    hireLabel.isHidden = !user.forHire || size == .small
    setNeedsLayout()
  }
}

// MARK: - MiniProfileView.Size

extension MiniProfileView {
  enum Size {
    case regular
    case small
  }
}

// MARK: - MiniProfileView Preview

#Preview {
  UIStackView(axis: .vertical, spacing: 20) {
    MiniProfileView().then {
      $0.configure(.preview)
    }
    MiniProfileView(.small).then {
      $0.configure(.preview)
    }
  }
}
