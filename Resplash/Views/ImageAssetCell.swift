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
    colors: [.black.withAlphaComponent(0), .black.withAlphaComponent(0.65)],
    startPoint: .zero,
    endPoint: CGPoint(x: 0, y: 1)
  )

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
  }

  private let profileView = MiniProfileView().then {
    $0.overrideUserInterfaceStyle = .dark
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
    }

    contentView.addSubview(profileView)
    profileView.snp.makeConstraints {
      $0.top.equalTo(gradientView).inset(16)
      $0.leading.trailing.bottom.equalToSuperview().inset(16)
    }

    contentView.clipsToBounds = true
    contentView.layer.cornerRadius = 12
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = UIColor.separator.cgColor
    registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
      self.contentView.layer.borderColor = UIColor.separator.cgColor
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ asset: ImageAsset) {
    estimatedImageSize = CGSize(width: asset.width, height: asset.height)

    let newURL = URL(string: asset.imageURL.regular.absoluteString.replacingOccurrences(of: "w=1080", with: "w=800"))
    imageView.kf.setImage(with: newURL)
    profileView.configure(asset.user)
  }

  override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    guard let size = estimatedImageSize else {
      return super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
    let ratio = targetSize.width / CGFloat(size.width)
    return CGSize(width: CGFloat(size.width) * ratio, height: CGFloat(size.height) * ratio)
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
