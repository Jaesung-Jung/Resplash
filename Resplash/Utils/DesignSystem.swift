//
//  DesignSystem.swift
//  Resplash
//
//  Created by 정재성 on 7/8/25.
//

import SwiftUI

// MARK: - UIColor

extension UIColor {
  static let app = AppColor.self

  enum AppColor {
    static let background = UIColor(light: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), dark: #colorLiteral(red: 0.06274509804, green: 0.06274509804, blue: 0.07450980392, alpha: 1))
    static let shadow = UIColor(light: #colorLiteral(red: 0.06274509804, green: 0.06274509804, blue: 0.07450980392, alpha: 0.3038855546), dark: #colorLiteral(red: 0.06274509804, green: 0.06274509804, blue: 0.07450980392, alpha: 0.7))
    static let imagePlaceholder = UIColor.systemGray5

    static let red = UIColor.systemRed

    static let primary = UIColor.label
    static let secondary = UIColor.secondaryLabel

    static let separator = UIColor.separator

    static let gray = UIColor.systemGray
    static let gray2 = UIColor.systemGray2
    static let gray3 = UIColor.systemGray3
    static let gray4 = UIColor.systemGray4
    static let gray5 = UIColor.systemGray5
    static let gray6 = UIColor.systemGray6
  }
}

// MARK: - CGColor

extension CGColor {
  static let app = AppColor.self

  @dynamicMemberLookup
  enum AppColor {
    static subscript(dynamicMember keyPath: KeyPath<UIColor.AppColor.Type, UIColor>) -> CGColor {
      UIColor.app[keyPath: keyPath].cgColor
    }
  }
}

// MARK: - Color

extension Color {
  static let app = AppColor.self

  @dynamicMemberLookup
  enum AppColor {
    static subscript(dynamicMember keyPath: KeyPath<UIColor.AppColor.Type, UIColor>) -> Color {
      Color(uiColor: UIColor.app[keyPath: keyPath])
    }
  }
}

extension ShapeStyle where Self == Color {
  static var app: Color.AppColor.Type { Color.app }
}
