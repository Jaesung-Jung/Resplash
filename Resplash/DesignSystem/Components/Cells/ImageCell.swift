//
//  ImageCell.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

import UIKit
import SnapKit

final class ImageCell: UICollectionViewCell {
  private var estimatedImageSize: CGSize?

  private let topGradientView = GradientView(
    colors: [.black.withAlphaComponent(0.65), .black.withAlphaComponent(0)],
    startPoint: .zero,
    endPoint: CGPoint(x: 0, y: 1)
  )

  private let bottomGradientView = GradientView(
    colors: [.black.withAlphaComponent(0), .black.withAlphaComponent(0.65)],
    startPoint: .zero,
    endPoint: CGPoint(x: 0, y: 1)
  )

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.backgroundColor = .app.gray5
  }

  private let likeView = LikeView().then {
    $0.overrideUserInterfaceStyle = .dark
  }

  private let profileView = ProfileView().then {
    $0.overrideUserInterfaceStyle = .dark
  }

  private lazy var menuButton = UIButton(configuration: .prominentGlass(.plain())).then {
    $0.configuration?.image = UIImage(
      systemName: "ellipsis",
      withConfiguration: UIImage.SymbolConfiguration(textStyle: .subheadline)
    )
    if #unavailable(iOS 26.0) {
      $0.configuration?.background.visualEffect = UIBlurEffect(style: .prominent)
    }
    $0.configuration?.cornerStyle = .capsule
    $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    $0.showsMenuAsPrimaryAction = true
    if #available(iOS 26.0, *) {
      $0.tintColor = UIColor(light: .white, dark: .clear)
    } else {
      $0.tintColor = .app.primary
    }
    $0.isHidden = true
    $0.setContentHuggingPriority(.required, for: .horizontal)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  var menuButtonSize: MenuButtonSize = .regular {
    didSet {
      guard oldValue != menuButtonSize else {
        return
      }
      switch menuButtonSize {
      case .compact:
        menuButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        menuButton.maximumContentSizeCategory = .extraExtraExtraLarge
        menuButton.snp.updateConstraints {
          $0.trailing.bottom.equalToSuperview().inset(10)
        }
      case .regular:
        menuButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        menuButton.maximumContentSizeCategory = .accessibilityExtraExtraExtraLarge
        menuButton.snp.updateConstraints {
          $0.trailing.bottom.equalToSuperview().inset(16)
        }
      }
    }
  }

  var menu: UIMenu? {
    get { menuButton.menu }
    set {
      menuButton.menu = newValue
      menuButton.isHidden = newValue == nil
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    contentView.addSubview(topGradientView)
    topGradientView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
    }

    contentView.addSubview(likeView)
    likeView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(16)
      $0.bottom.equalTo(topGradientView).inset(16)
    }

    contentView.addSubview(bottomGradientView)
    bottomGradientView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
    }

    contentView.addSubview(profileView)
    profileView.snp.makeConstraints {
      $0.top.equalTo(bottomGradientView).inset(16)
      $0.leading.bottom.equalToSuperview().inset(16)
    }

    contentView.addSubview(menuButton)
    menuButton.snp.makeConstraints {
      $0.leading.greaterThanOrEqualTo(profileView.snp.trailing).offset(4)
      $0.trailing.bottom.equalToSuperview().inset(16)
    }

    contentView.clipsToBounds = true
    contentView.layer.borderColor = .app.gray5
    registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
      self.contentView.layer.borderColor = .app.gray5
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ image: ImageAsset, size: Size) {
    estimatedImageSize = CGSize(width: image.width, height: image.height)
    imageView.setImageURL(image.url.sd)

    switch size {
    case .compact:
      contentView.layer.cornerRadius = 0
      menuButtonSize = .compact
      contentView.layer.borderWidth = .zero
      likeView.isHidden = true
      profileView.isHidden = true
      topGradientView.isHidden = true
      bottomGradientView.isHidden = true

    case .regular:
      contentView.layer.cornerRadius = 12
      menuButtonSize = .regular
      contentView.layer.borderWidth = 1
      likeView.isHidden = false
      profileView.isHidden = false
      topGradientView.isHidden = false
      bottomGradientView.isHidden = false

      likeView.count = image.likes
      profileView.user = image.user
    }
  }

  override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    guard let size = estimatedImageSize else {
      return super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
    switch (horizontalFittingPriority, verticalFittingPriority) {
    case (.fittingSizeLevel, .required):
      let ratio = targetSize.height / CGFloat(size.height)
      return CGSize(width: CGFloat(size.width) * ratio, height: CGFloat(size.height) * ratio)
    case (.required, .fittingSizeLevel):
      let ratio = targetSize.width / CGFloat(size.width)
      return CGSize(width: CGFloat(size.width) * ratio, height: CGFloat(size.height) * ratio)
    default:
      return super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
  }
}

// MARK: - ImageCell.Size

extension ImageCell {
  enum Size {
    case compact
    case regular
  }
}

// MARK: - ImageCell.MenuButtonSize

extension ImageCell {
  enum MenuButtonSize {
    case compact
    case regular
  }
}

// MARK: - ImageCell Preview

#if DEBUG

#Preview {
  ImageCell().then {
    $0.configure(.preview, size: .regular)
    $0.snp.makeConstraints {
      $0.width.equalTo(400)
      $0.height.equalTo(266)
    }
  }
}

#endif
