//
//  TrendCell.swift
//  Resplash
//
//  Created by 정재성 on 7/29/25.
//

import UIKit
import SnapKit

final class TrendCell: UICollectionViewCell {
  private let imageView = CircularImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.cornerRadius = 8
    $0.backgroundColor = .app.gray5
  }

  private let titleLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .title2).withWeight(.heavy)
    $0.setContentHuggingPriority(.required, for: .vertical)
    $0.setContentCompressionResistancePriority(.required, for: .vertical)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  private let growthImageView = UIImageView().then {
    $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .subheadline).withWeight(.semibold))
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  private let growthLabel = UILabel().then {
    $0.font = .preferredFont(forTextStyle: .subheadline).withWeight(.semibold)
    $0.setContentHuggingPriority(.required, for: .horizontal)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  private let highlightedBackgroundView = UIView().then {
    $0.backgroundColor = .app.gray5
    $0.cornerRadius = 8
    $0.alpha = 0
  }

  override var isHighlighted: Bool {
    didSet {
      let alpha: CGFloat = isHighlighted ? 1 : 0
      let animator = UIViewPropertyAnimator.snappy()
      animator.addAnimations {
        self.highlightedBackgroundView.alpha = alpha
      }
      animator.startAnimation()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(highlightedBackgroundView)
    highlightedBackgroundView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(-8)
    }

    contentView.addSubview(imageView)
    contentView.addSubview(titleLabel)

    imageView.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.top.bottom.equalTo(titleLabel)
      $0.width.equalTo(imageView.snp.height)
    }

    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(imageView.snp.trailing).offset(8)
      $0.top.bottom.equalToSuperview().inset(16)
    }

    let growthStackView = UIStackView(axis: .horizontal, spacing: 4) {
      growthLabel
      growthImageView
    }
    contentView.addSubview(growthStackView)
    growthStackView.snp.makeConstraints {
      $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
      $0.trailing.equalToSuperview()
      $0.centerY.equalToSuperview()
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ keyword: Trend.Keyword) {
    switch keyword.growth {
    case let growth where growth > 0:
      growthImageView.image = UIImage(systemName: "arrow.turn.right.up")
      growthImageView.tintColor = .systemGreen
      growthLabel.textColor = .systemGreen
    case let growth where growth < 0:
      growthImageView.image = UIImage(systemName: "arrow.turn.right.down")
      growthImageView.tintColor = .systemRed
      growthLabel.textColor = .systemRed
    default:
      growthImageView.image = UIImage(systemName: "arrow.right")
      growthImageView.tintColor = .systemGray
      growthLabel.textColor = .systemGray
    }

    imageView.setImageURL(keyword.thumbnailURL.sd)
    titleLabel.text = keyword.title
    growthLabel.text = "\(keyword.growth.formatted(.number))%"
  }
}

// MARK: - TrendCell Preview

#if DEBUG

#Preview {
  TrendCell().then {
    $0.configure(Trend.preview.keywords[0])
    $0.snp.makeConstraints {
      $0.width.equalTo(300)
      $0.height.equalTo(80)
    }
  }
}

#endif
