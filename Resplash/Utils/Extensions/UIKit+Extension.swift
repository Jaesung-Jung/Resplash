//
//  UIKit+Extension.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

import UIKit

// MARK: - UIView (Corner)

extension UIView {
  @objc dynamic var cornerRadius: CGFloat {
    get { layer.cornerRadius }
    set { layer.cornerRadius = newValue }
  }

  @objc dynamic var maskedCorners: CACornerMask {
    get { layer.maskedCorners }
    set { layer.maskedCorners = newValue }
  }

  @objc dynamic var cornerCurve: CALayerCornerCurve {
    get { layer.cornerCurve }
    set { layer.cornerCurve = newValue }
  }
}

// MARK: - UIColor (Dynamic Color)

extension UIColor {
  convenience init(light: UIColor, dark: UIColor) {
    self.init { traitCollection in
      switch traitCollection.userInterfaceStyle {
      case .dark:
        return dark
      default:
        return light
      }
    }
  }
}

// MARK: - UIFont

extension UIFont {
  @inlinable func withWeight(_ weight: UIFont.Weight) -> UIFont {
    guard let textStyle = fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.textStyle] as? UIFont.TextStyle else {
      return self
    }
    let traitCollection = UITraitCollection(preferredContentSizeCategory: .large)
    let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle, compatibleWith: traitCollection)
    return UIFontMetrics(forTextStyle: textStyle).scaledFont(
      for: .systemFont(ofSize: descriptor.pointSize, weight: weight),
      compatibleWith: nil
    )
  }
}

// MARK: - UIStackView

extension UIStackView {
  convenience init(
    axis: NSLayoutConstraint.Axis,
    distribution: UIStackView.Distribution = .fill,
    alignment: UIStackView.Alignment = .fill,
    spacing: CGFloat = 0,
    @ArrayBuilder<UIView> arrangedSubviews: () -> [UIView]
  ) {
    self.init(arrangedSubviews: arrangedSubviews())
    self.axis = axis
    self.distribution = distribution
    self.alignment = alignment
    self.spacing = spacing
  }
}

// MARK: - NSDiffableDataSourceSnapshot

extension NSDiffableDataSourceSnapshot {
  mutating func appendItems(to section: SectionIdentifierType, @ArrayBuilder<ItemIdentifierType> items: () -> [ItemIdentifierType]) {
    appendItems(items(), toSection: section)
  }
}

// MARK: - UIButton.Configuration (Under iOS 26 Compatible)

extension UIButton.Configuration {
  @inlinable static func glass(_ either: @autoclosure () -> UIButton.Configuration) -> UIButton.Configuration {
    if #available(iOS 26.0, *) {
      return .glass()
    } else {
      return either()
    }
  }

  @inlinable static func prominentGlass(_ either: @autoclosure () -> UIButton.Configuration) -> UIButton.Configuration {
    if #available(iOS 26.0, *) {
      return .prominentGlass()
    } else {
      return either()
    }
  }
}

// MARK: - UIImageView (URL)

#if canImport(Kingfisher)
import Kingfisher
#endif

extension UIImageView {
  func setImageURL(_ url: URL?, completion: (() -> Void)? = nil) {
    if let url {
      kf.setImage(with: url, options: [.transition(.fade(0.25))]) { _ in
        completion?()
      }
    } else {
      image = nil
      completion?()
    }
  }
}

// MARK: - UISpringTimingParameters

extension UITimingCurveProvider where Self == UISpringTimingParameters {
  @inlinable static func smooth(duration: CGFloat, initialVelocity: CGVector = .zero) -> UISpringTimingParameters {
    UISpringTimingParameters(duration: duration, bounce: 0.0, initialVelocity: initialVelocity)
  }

  @inlinable static func snappy(duration: CGFloat, initialVelocity: CGVector = .zero) -> UISpringTimingParameters {
    UISpringTimingParameters(duration: duration, bounce: 0.15, initialVelocity: initialVelocity)
  }

  @inlinable static func bouncy(duration: CGFloat, initialVelocity: CGVector = .zero) -> UISpringTimingParameters {
    UISpringTimingParameters(duration: duration, bounce: 0.3, initialVelocity: initialVelocity)
  }
}

// MARK: - UIViewPropertyAnimator

extension UIViewPropertyAnimator {
  @inlinable static func smooth(duration: TimeInterval = 0.5, initialVelocity: CGVector = .zero) -> UIViewPropertyAnimator {
    UIViewPropertyAnimator(duration: duration, timingParameters: .smooth(duration: duration, initialVelocity: initialVelocity))
  }

  @inlinable static func snappy(duration: TimeInterval = 0.3, initialVelocity: CGVector = .zero) -> UIViewPropertyAnimator {
    UIViewPropertyAnimator(duration: duration, timingParameters: .snappy(duration: duration, initialVelocity: initialVelocity))
  }

  @inlinable static func bouncy(duration: CGFloat = 0.5, initialVelocity: CGVector = .zero) -> UIViewPropertyAnimator {
    UIViewPropertyAnimator(duration: duration, timingParameters: .bouncy(duration: duration, initialVelocity: initialVelocity))
  }
}
