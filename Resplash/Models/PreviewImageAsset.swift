//
//  PreviewImageAsset.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import Foundation

struct PreviewImageAsset: Identifiable {
  let id: String
  let imageURL: ImageAssetURL
}

// MARK: - PreviewImageAsset (Hashable)

extension PreviewImageAsset: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - PreviewImageAsset(Decodable)

extension PreviewImageAsset: Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case imageURL = "urls"
  }
}
