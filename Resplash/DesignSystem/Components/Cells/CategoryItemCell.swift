//
//  CategoryItemCell.swift
//  Resplash
//
//  Created by 정재성 on 7/28/25.
//

import UIKit
import SnapKit

final class CategoryItemCell: UICollectionViewCell {
  private var estimatedImageSize: CGSize?

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.cornerRadius = 8
    $0.backgroundColor = .app.gray5
  }

  private let titleLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .body).withWeight(.bold)
  }

  private let subtitleLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .subheadline).withWeight(.medium)
    $0.textColor = .app.secondary
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }

    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(imageView.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview()
    }

    contentView.addSubview(subtitleLabel)
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(4)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ item: Category.Item) {
    imageView.setImageURL(item.coverImageURL.sd)
    titleLabel.text = item.title
    subtitleLabel.text = .localized("\(item.imageCount.formatted(.number))+ images")
  }
}

// MARK: - FeaturedItemCell Preview

#if DEBUG

#Preview {
  CategoryItemCell().then {
    $0.configure(.preview)
    $0.snp.makeConstraints {
      $0.width.equalTo(300)
      $0.height.equalTo(230)
    }
  }
}

#endif
