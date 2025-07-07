//
//  ImageAssetCell.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

import UIKit
import SnapKit
import Kingfisher

class ImageAssetCell: UICollectionViewCell {
  private var estimatedImageSize: CGSize?

  private let gradientView = GradientView(
    colors: [.black.withAlphaComponent(0), .black.withAlphaComponent(0.5)],
    startPoint: .zero,
    endPoint: CGPoint(x: 0, y: 1)
  )

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
  }

  private let profileImageBackgroundView = UIView().then {
    $0.backgroundColor = .white
  }

  private let profileImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    $0.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
    $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
    $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
  }

  private let userNameLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
    $0.textColor = .white
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    contentView.addSubview(gradientView)
    gradientView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalToSuperview().multipliedBy(0.3)
    }

    contentView.addSubview(profileImageBackgroundView)
    profileImageBackgroundView.snp.makeConstraints {
      $0.leading.bottom.equalToSuperview().inset(16)
      $0.width.equalTo(profileImageBackgroundView.snp.height)
      $0.height.greaterThanOrEqualTo(30)
    }

    contentView.addSubview(profileImageView)
    profileImageView.snp.makeConstraints {
      $0.directionalEdges.equalTo(profileImageBackgroundView).inset(1)
    }

    contentView.addSubview(userNameLabel)
    userNameLabel.snp.makeConstraints {
      $0.leading.equalTo(profileImageBackgroundView.snp.trailing).offset(8)
      $0.top.bottom.equalTo(profileImageBackgroundView)
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ asset: ImageAsset) {
    estimatedImageSize = CGSize(width: asset.width, height: asset.height)
    imageView.kf.setImage(with: asset.imageURL.regular)
    profileImageView.kf.setImage(with: asset.user.imageURL.medium)
    userNameLabel.text = asset.user.name
  }

  override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    guard let size = estimatedImageSize else {
      return super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
    let ratio = targetSize.width / CGFloat(size.width)
    return CGSize(width: CGFloat(size.width) * ratio, height: CGFloat(size.height) * ratio)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    profileImageBackgroundView.layoutIfNeeded()
    profileImageBackgroundView.layer.cornerRadius = profileImageBackgroundView.frame.height * 0.5
    profileImageView.layer.cornerRadius = (profileImageBackgroundView.frame.height - 1) * 0.5
  }
}

// MARK: - ImageAssetCell Preview

#if DEBUG

#Preview {
  ImageAssetCell().then {
    $0.configure(.preview)
    $0.snp.makeConstraints {
      $0.width.equalTo(400)
      $0.height.equalTo(266)
    }
  }
}

#endif
