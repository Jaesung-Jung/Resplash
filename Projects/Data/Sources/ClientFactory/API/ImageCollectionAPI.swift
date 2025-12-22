//
//  ImageCollectionAPI.swift
//
//  Copyright © 2025 Jaesung Jung. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import ResplashEntities
import ResplashNetworking

extension Endpoint {
  public static func collections(for mediaType: Unsplash.MediaType, page: Int, count: Int) -> Endpoint {
    let assetType = switch mediaType {
    case .photo:
      "photos"
    case .illustration:
      "illustrations"
    }
    return Endpoint(
      resourceId: "\(assetType)_collections_\(page)",
      path: "napi/collections",
      method: .get,
      parameters: [
        "asset_type": assetType,
        "page": page,
        "per_page": count
      ]
    )
  }

  public static func collectionImages(for collection: Unsplash.ImageCollection, page: Int, count: Int) -> Endpoint {
    Endpoint(
      resourceId: "collection_images_\(page)",
      path: "napi/collections/\(collection.id)/photos",
      method: .get,
      parameters: [
        "page": page,
        "per_page": count,
        "share_key": collection.shareKey
      ]
    )
  }
}
