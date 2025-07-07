//
//  UIKit+Extension.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

import UIKit

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
    @ArrangedSubviewBuilder<UIView> arrangedSubviews: () -> [UIView]
  ) {
    self.init(arrangedSubviews: arrangedSubviews())
    self.axis = axis
    self.distribution = distribution
    self.alignment = alignment
    self.spacing = spacing
  }
}

// MARK: - UIStackView.ArrangedSubviewBuilder

extension UIStackView {
  @resultBuilder struct ArrangedSubviewBuilder<Item: UIView> {
    static func buildBlock(_ items: Item...) -> [Item] {
      items
    }

    static func buildBlock(_ items: [Item]...) -> [Item] {
      items.flatMap { $0 }
    }

    static func buildOptional(_ items: [Item]?) -> [Item] {
      items ?? []
    }

    static func buildEither(first items: [Item]) -> [Item] {
      items
    }

    static func buildEither(second items: [Item]) -> [Item] {
      items
    }

    static func buildExpression(_ expression: Item) -> [Item] {
      [expression]
    }

    static func buildExpression<C: Collection>(_ expression: C) -> [Item] where C.Element == Item {
      Array(expression)
    }

    static func buildArray(_ components: [[Item]]) -> [Item] {
      components.flatMap { $0 }
    }

    static func buildLimitedAvailability(_ component: [Item]) -> [Item] {
      component
    }
  }
}
