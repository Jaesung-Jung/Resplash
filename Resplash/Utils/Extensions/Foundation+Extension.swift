//
//  Foundation+Extension.swift
//  Resplash
//
//  Created by 정재성 on 7/8/25.
//

import Foundation

extension String {
  @inlinable nonisolated static func localized(_ keyAndValue: String.LocalizationValue, comment: StaticString? = nil) -> String {
    String(localized: keyAndValue, comment: comment)
  }
}
