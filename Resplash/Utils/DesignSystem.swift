//
//  DesignSystem.swift
//  Resplash
//
//  Created by 정재성 on 7/8/25.
//

import UIKit

extension UIColor {
  static let app = AppColor.self

  enum AppColor {
    static let background = UIColor(light: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), dark: #colorLiteral(red: 0.06274509804, green: 0.06274509804, blue: 0.07450980392, alpha: 1))
    static let shadow = UIColor(light: #colorLiteral(red: 0.06274509804, green: 0.06274509804, blue: 0.07450980392, alpha: 0.3038855546), dark: #colorLiteral(red: 0.06274509804, green: 0.06274509804, blue: 0.07450980392, alpha: 0.7))
  }
}
