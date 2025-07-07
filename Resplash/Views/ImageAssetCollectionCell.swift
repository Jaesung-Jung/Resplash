//
//  ImageAssetCollectionCell.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

import UIKit
import SnapKit
import Kingfisher

final class ImageAssetCollectionCell: UICollectionViewCell {
  private let imageViews = repeatElement((), count: 3).map {
    UIImageView().then {
      $0.contentMode = .scaleAspectFill
      $0.clipsToBounds = true
      $0.backgroundColor = .systemGray5
    }
  }

  private let titleLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .body).withWeight(.heavy)
    $0.setContentHuggingPriority(.required, for: .vertical)
    $0.setContentCompressionResistancePriority(.required, for: .vertical)
  }

  private let infoLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .footnote).withWeight(.semibold)
    $0.textColor = .secondaryLabel
    $0.setContentHuggingPriority(.required, for: .vertical)
    $0.setContentCompressionResistancePriority(.required, for: .vertical)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    let imageStackView = UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 2) {
      imageViews[0]
      UIStackView(axis: .vertical, distribution: .fillEqually, spacing: 2) {
        imageViews[1]
        imageViews[2]
      }
    }.then {
      $0.clipsToBounds = true
      $0.layer.cornerRadius = 12
    }
    contentView.addSubview(imageStackView)
    imageStackView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }

    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(imageStackView.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview()
    }

    contentView.addSubview(infoLabel)
    infoLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(4)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ collection: ImageAssetCollection) {
    for imageView in imageViews {
      imageView.image = nil
    }
    for (imageView, image) in zip(imageViews, collection.previewImages) {
      imageView.kf.setImage(with: image.imageURL.small)
    }
    titleLabel.text = collection.title
    infoLabel.text = "\(collection.totalImages.formatted(.number)) image"
  }
}

// MARK: - ImageAssetCollectionCell Preview

#Preview {
  ImageAssetCollectionCell().then {
    $0.configure(.preview)
    $0.snp.makeConstraints {
      $0.width.equalTo(390)
      $0.height.equalTo(200).priority(240)
    }
  }
}
