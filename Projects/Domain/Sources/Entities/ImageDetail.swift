//
//  ImageDetail.swift
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

import MemberwiseInit

extension Unsplash {
  @MemberwiseInit(.public)
  @dynamicMemberLookup
  public struct ImageDetail: Identifiable, Hashable, Sendable {
    public var id: String { image.id }
    public let image: Unsplash.Image
    public let views: Int
    public let downloads: Int
    public let exif: Unsplash.ImageDetail.Exif?
    public let location: Unsplash.ImageDetail.Location?
    public let topics: [Unsplash.ImageDetail.Topic]
    public let tags: [Unsplash.ImageDetail.Tag]

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<Unsplash.Image, T>) -> T {
      image[keyPath: keyPath]
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(image)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.image == rhs.image
    }
  }
}

// MARK: - Unsplash.ImageDetail.Exif

extension Unsplash.ImageDetail {
  @MemberwiseInit(.public)
  public struct Exif: Sendable {
    public let brand: String?
    public let model: String?
    public let name: String?
    public let exposure: String?
    public let aperture: String?
    public let focalLength: String?
    public let iso: Int?
  }
}

// MARK: - Unsplash.ImageDetail.Location

extension Unsplash.ImageDetail {
  @MemberwiseInit(.public)
  public struct Location: Sendable {
    public let name: String
    public let city: String?
    public let country: String
    public let position: (latitude: Double, longitude: Double)?
  }
}

// MARK: - Unsplash.ImageDetail.Topic

extension Unsplash.ImageDetail {
  @MemberwiseInit(.public)
  public struct Topic: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let slug: String
    public let visibility: String

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
  }
}

// MARK: - Unsplash.ImageDetail.Tag

extension Unsplash.ImageDetail {
  @MemberwiseInit(.public)
  public struct Tag: Hashable, Sendable {
    public let type: String
    public let title: String
  }
}
