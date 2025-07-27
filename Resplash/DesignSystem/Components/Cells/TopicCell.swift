//
//  TopicCell.swift
//  Resplash
//
//  Created by 정재성 on 7/9/25.
//

import UIKit
import SnapKit

final class TopicCell: UICollectionViewCell {
  private let effectView = UIVisualEffectView()

  private let effectBorderView = UIView().then {
    $0.layer.borderWidth = 1
  }

  private let coverImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
    $0.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
    $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical)
    $0.setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal)
  }

  private let titleLabel = UILabel().then {
    // Glass Effect Bug Fix
    $0.textColor = UIColor(light: .black, dark: .white)
    $0.font = .preferredFont(forTextStyle: .subheadline).withWeight(.semibold)
  }

  override var isHighlighted: Bool {
    didSet {
      if #unavailable(iOS 26.0) {
        effectView.contentView.alpha = isHighlighted ? 0.5 : 1
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    if #available(iOS 26.0, *) {
      effectView.effect = UIGlassEffect().then {
        $0.isInteractive = true
      }
    }

    contentView.addSubview(effectView)
    effectView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    effectView.contentView.addSubview(effectBorderView)
    effectBorderView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    effectView.contentView.addSubview(coverImageView)
    coverImageView.snp.makeConstraints {
      $0.top.bottom.leading.equalToSuperview().inset(4)
      $0.width.equalTo(coverImageView.snp.height)
    }

    effectView.contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints {
      $0.leading.equalTo(coverImageView.snp.trailing).offset(8)
      $0.top.bottom.equalToSuperview().inset(12)
      $0.trailing.equalToSuperview().inset(12)
    }

    let borderColor = if #available(iOS 26.0, *) {
      UIColor(light: .app.gray5, dark: .clear)
    } else {
      UIColor.app.gray5
    }
    effectBorderView.layer.borderColor = borderColor.cgColor
    registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _ ) in
      self.effectBorderView.layer.borderColor = borderColor.cgColor
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ topic: Topic) {
    coverImageView.setImageURL(topic.coverImage.url.low)
    titleLabel.text = topic.title
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    effectBorderView.layer.cornerRadius = bounds.height * 0.5
    effectView.layer.cornerRadius = bounds.height * 0.5
    coverImageView.layer.cornerRadius = bounds.insetBy(dx: 4, dy: 4).height * 0.5
  }
}

// MARK: - TopicCell Preview

#if DEBUG

#Preview {
  TopicCell().then {
    $0.configure(.preview)
    $0.snp.makeConstraints {
      $0.width.equalTo(150)
      $0.height.equalTo(50)
    }
  }
}

#endif
