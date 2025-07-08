//
//  ShadowView.swift
//  Resplash
//
//  Created by 정재성 on 7/8/25.
//

import UIKit

final class ShadowView: UIView {
  var shadowColor: UIColor? {
    didSet {
      layer.shadowColor = shadowColor?.cgColor
    }
  }

  @inlinable var shadowOpacity: Float {
    get { layer.shadowOpacity }
    set { layer.shadowOpacity = newValue }
  }

  @inlinable var shadowOffset: CGSize {
    get { layer.shadowOffset }
    set { layer.shadowOffset = newValue }
  }

  @inlinable var shadowRadius: CGFloat {
    get { layer.shadowRadius }
    set { layer.shadowRadius = newValue }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
      self.layer.shadowColor = self.shadowColor?.cgColor
    }
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
  }
}
