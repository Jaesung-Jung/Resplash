//
//  ImageAssetCell.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

import UIKit
import SnapKit
import Kingfisher

final class ImageAssetCell: UICollectionViewCell {
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
  }

  private let likeView = LikeView().then {
    $0.overrideUserInterfaceStyle = .dark
  }

  private let profileView = MiniProfileView().then {
    $0.overrideUserInterfaceStyle = .dark
  }

  private lazy var menuButton = UIButton(configuration: .prominentGlass(.filled())).then {
    $0.configuration?.image = UIImage(
      systemName: "ellipsis",
      withConfiguration: UIImage.SymbolConfiguration(textStyle: .subheadline)
    )
    $0.configuration?.cornerStyle = .capsule
    $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    $0.showsMenuAsPrimaryAction = true
    if #available(iOS 26.0, *) {
      $0.tintColor = UIColor(light: .white, dark: .clear)
    } else {
      $0.tintColor = .white
    }
    $0.setContentHuggingPriority(.required, for: .horizontal)
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  override var cornerRadius: CGFloat {
    get { contentView.cornerRadius }
    set { contentView.cornerRadius = newValue }
  }

  @inlinable var isBorderHidden: Bool {
    get { contentView.layer.borderWidth == .zero }
    set { contentView.layer.borderWidth = newValue ? .zero : 1 }
  }

  @inlinable var isTopGradientHidden: Bool {
    get { topGradientView.isHidden }
    set { topGradientView.isHidden = newValue }
  }

  @inlinable var isBottomGradientHidden: Bool {
    get { bottomGradientView.isHidden }
    set { bottomGradientView.isHidden = newValue }
  }

  @inlinable var isProfileHidden: Bool {
    get { profileView.isHidden }
    set { profileView.isHidden = newValue }
  }

  var menu: UIMenu? {
    get { menuButton.menu }
    set { menuButton.menu = newValue }
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

    likeView.count = asset.likes
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
