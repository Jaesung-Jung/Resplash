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

// MARK: - ImageAssetURL (Preview)

#if DEBUG

extension ImageAssetURL {
  static let preview = ImageAssetURL(
    raw: URL(string: "https://images.unsplash.com/photo-1749738155703-b4650f21387b?ixid=M3wxMjA3fDF8MXxhbGx8MXx8fHx8fHx8MTc1MTU5ODIwOHw&ixlib=rb-4.1.0")!,
    full: URL(string: "https://images.unsplash.com/photo-1749738155703-b4650f21387b?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxMjA3fDF8MXxhbGx8MXx8fHx8fHx8MTc1MTU5ODIwOHw&ixlib=rb-4.1.0&q=85")!,
    regular: URL(string: "https://images.unsplash.com/photo-1749738155703-b4650f21387b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3wxMjA3fDF8MXxhbGx8MXx8fHx8fHx8MTc1MTU5ODIwOHw&ixlib=rb-4.1.0&q=80&w=1080")!,
    small: URL(string: "https://images.unsplash.com/photo-1749738155703-b4650f21387b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3wxMjA3fDF8MXxhbGx8MXx8fHx8fHx8MTc1MTU5ODIwOHw&ixlib=rb-4.1.0&q=80&w=400")!,
    thumb: URL(string: "https://images.unsplash.com/photo-1749738155703-b4650f21387b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3wxMjA3fDF8MXxhbGx8MXx8fHx8fHx8MTc1MTU5ODIwOHw&ixlib=rb-4.1.0&q=80&w=200")!,
    smallS3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1749738155703-b4650f21387b")!
  )
}

#endif
