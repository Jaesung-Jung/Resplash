//
//  ImageAssetURL.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import Foundation

struct ImageAssetURL {
  let raw: URL
  let full: URL
  let regular: URL
  let small: URL
  let thumb: URL
  let smallS3: URL
}

// MARK: - ImageAssetURL (Decodable)

extension ImageAssetURL: Decodable {
  enum CodingKeys: String, CodingKey {
    case raw
    case full
    case regular
    case small
    case thumb
    case smallS3 = "small_s3"
  }
}
