//
//  CircularImageView.swift
//  Resplash
//
//  Created by 정재성 on 7/29/25.
//

import UIKit

final class CircularImageView: UIImageView {
  override var intrinsicContentSize: CGSize {
    let imageSize = image?.size ?? .zero
    let size = min(imageSize.width, imageSize.height)
    return CGSize(width: size, height: size)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    clipsToBounds = true
    cornerRadius = max(bounds.width, bounds.height) * 0.5
  }
}
