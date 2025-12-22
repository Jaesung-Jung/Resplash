//
//  ImageAPI.swift
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
  public static func photos(page: Int, count: Int) -> Endpoint {
    Endpoint(
      resourceId: "photos_\(page)",
      path: "napi/photos",
      method: .get,
      parameters: [
        "page": page,
        "per_page": count
      ]
    )
  }

  public static func illustrations(page: Int, count: Int) -> Endpoint {
    Endpoint(
      resourceId: "illustrations_\(page)",
      path: "napi/illustrations",
      method: .get,
      parameters: [
        "page": page,
        "per_page": count
      ]
    )
  }

  public static func relatedImages(for image: Unsplash.Image, page: Int, count: Int) -> Endpoint {
    Endpoint(
      resourceId: "related_images_\(page)",
      path: "napi/photos/\(image.slug)/related",
      method: .get,
      parameters: [
        "page": page,
        "per_page": count
      ]
    )
  }

  public static func seriesImages(for image: Unsplash.Image) -> Endpoint {
    Endpoint(
      resourceId: "series_images",
      path: "napi/photos/\(image.slug)/series",
      method: .get,
      parameters: [
        "limit": 10
      ]
    )
  }

  public static func detail(for image: Unsplash.Image) -> Endpoint {
    Endpoint(
      resourceId: "\(image.type)_detail",
      path: "napi/photos/\(image.slug)",
      method: .get
    )
  }
}
