//
//  MediaType.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import Foundation

enum MediaType: String, Decodable {
  case photo
  case illustration
}

// MARK: - MediaType (CustomStringConvertible)

extension MediaType: CustomStringConvertible {
  var description: String {
    switch self {
    case .photo:
      return .localized("Photos")
    case .illustration:
      return .localized("Illustrations")
    }
  }
}
