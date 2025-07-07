//
//  UIKit+Extension.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

import UIKit

extension UIFont {
  @inlinable func withWeight(_ weight: UIFont.Weight) -> UIFont {
    guard let textStyle = fontDescriptor.fontAttributes[UIFontDescriptor.AttributeName.textStyle] as? UIFont.TextStyle else {
      return self
    }
    return UIFontMetrics(forTextStyle: textStyle).scaledFont(
      for: .systemFont(ofSize: pointSize, weight: weight),
      compatibleWith: nil
    )
  }
}
