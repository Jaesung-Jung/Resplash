//
//  DataTransformer.swift
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

import Foundation
import ResplashEntities
import ResplashUtils

// MARK: - DataTransformer

protocol DataTransformer {
  associatedtype Output
  associatedtype Container

  static func container(from decoder: any Decoder) throws -> Container
  static func transform(from container: Container) throws -> Output
}

extension DataTransformer where Container == KeyedDecodingContainer<StringCodingKey> {
  static func container(from decoder: any Decoder) throws -> KeyedDecodingContainer<StringCodingKey> {
    try decoder.container(keyedBy: StringCodingKey.self)
  }
}

extension DataTransformer where Container == any SingleValueDecodingContainer {
  static func container(from decoder: any Decoder) throws -> any SingleValueDecodingContainer {
    try decoder.singleValueContainer()
  }
}

extension DataTransformer where Output: RawRepresentable, Output.RawValue == String, Container == any SingleValueDecodingContainer {
  static func transform(from container: Container) throws -> Output {
    let value = try container.decode(String.self)
    guard let output = Output(rawValue: value) else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Cannot initialize \(String(describing: Output.self)) from invalid String value \(value)"
        )
      )
    }
    return output
  }
}

// MARK: - MediaTypeDataTransformer

struct MediaTypeTransformer: DataTransformer {
  typealias Output = MediaType
  typealias Container = any SingleValueDecodingContainer
}

// MARK: - ShareLinkTransformer

struct ShareLinkTransformer: DataTransformer {
  static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> URL {
    try container.decode(URL.self, forKey: "html")
  }
}

// MARK: - ImageURLTransformer

struct ImageURLTransformer: DataTransformer {
  static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> ImageURL {
    let targetContainer = (try? container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "urls")) ?? container
    return try ImageURL(
      raw: targetContainer.decode(URL.self, forKey: "raw"),
      full: targetContainer.decode(URL.self, forKey: "full"),
      s3: targetContainer.decode(URL.self, forKey: "small_s3")
    )
  }
}

// MARK: - UserTransformer

struct UserTransformer: DataTransformer {
  static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> User {
    try User(
      id: container.decode(String.self, forKey: "id"),
      userId: container.decode(String.self, forKey: "username"),
      updatedAt: container.decode(Date.self, forKey: "updated_at"),
      forHire: container.decode(Bool.self, forKey: "for_hire"),
      name: container.decode(String.self, forKey: "name"),
      bio: container.decodeIfPresent(String.self, forKey: "bio"),
      location: container.decodeIfPresent(String.self, forKey: "location"),
      profileImageURL: container.decode(DTO<ProfileImageURLTransformer>.self, forKey: "profile_image").domain,
      totalLikes: container.decode(Int.self, forKey: "total_likes"),
      totalCollections: container.decode(Int.self, forKey: "total_collections"),
      totalPhotos: container.decode(Int.self, forKey: "total_photos"),
      totalIllustrations: container.decode(Int.self, forKey: "total_illustrations"),
      socials: container.decode(DTO<SocialTransformer>.self, forKey: "social").domain,
      shareLink: container.decode(DTO<ShareLinkTransformer>.self, forKey: "links").domain,
      imageURLs: container.decodeIfPresent([DTO<ImageURLTransformer>].self, forKey: "photos")?.map(\.domain) ?? []
    )
  }
}

// MARK: - UserTransformer.ProfileImageURLTransformer

extension UserTransformer {
  struct ProfileImageURLTransformer: DataTransformer {
    static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> User.ProfileImageURL {
      try User.ProfileImageURL(
        small: container.decode(URL.self, forKey: "small"),
        medium: container.decode(URL.self, forKey: "medium"),
        large: container.decode(URL.self, forKey: "large")
      )
    }
  }
}

// MARK: - UserTransformer.SocialTransformer

extension UserTransformer {
  struct SocialTransformer: DataTransformer {
    static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> [User.Social] {
      try container.allKeys.compactMap {
        switch $0.stringValue {
        case "twitter_username":
          try container.decodeIfPresent(String.self, forKey: $0).map { .twitter($0) }
        case "instagram_username":
          try container.decodeIfPresent(String.self, forKey: $0).map { .instagram($0) }
        case "paypal":
          try container.decodeIfPresent(String.self, forKey: $0).map { .paypal($0) }
        case "portfolio_url":
          try container.decodeIfPresent(URL.self, forKey: $0).map { .portfolio($0) }
        default:
          nil
        }
      }
    }
  }
}

// MARK: - AssetTransformer

struct AssetTransformer: DataTransformer {
  static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> Asset {
    try Asset(
      id: container.decode(String.self, forKey: "id"),
      slug: container.decode(String.self, forKey: "slug"),
      createdAt: container.decode(Date.self, forKey: "created_at"),
      updatedAt: container.decode(Date.self, forKey: "updated_at"),
      type: container.decode(DTO<MediaTypeTransformer>.self, forKey: "asset_type").domain,
      isPremium: container.decodeIfPresent(Bool.self, forKey: "premium") ?? false,
      description: container.decodeIfPresent(String.self, forKey: "description") ?? container.decodeIfPresent(String.self, forKey: "alt_description"),
      likes: container.decode(Int.self, forKey: "likes"),
      width: container.decode(CGFloat.self, forKey: "width"),
      height: container.decode(CGFloat.self, forKey: "height"),
      color: container.decode(String.self, forKey: "color"),
      url: container.decode(DTO<ImageURLTransformer>.self, forKey: "urls").domain,
      user: container.decode(DTO<UserTransformer>.self, forKey: "user").domain,
      shareLink: container.decode(DTO<ShareLinkTransformer>.self, forKey: "links").domain
    )
  }
}

// MARK: - AssetDetailTransformer

struct AssetDetailTransformer: DataTransformer {
  static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> AssetDetail {
    try AssetDetail(
      image: AssetTransformer.transform(from: container),
      views: container.decode(Int.self, forKey: "views"),
      downloads: container.decode(Int.self, forKey: "downloads"),
      exif: container.decodeIfPresent(DTO<ExifTransformer>.self, forKey: "exif")?.domain,
      location: container.decodeIfPresent(DTO<LocationTransformer>.self, forKey: "location")?.domain,
      topics: container.decodeIfPresent([DTO<TopicTransformer>].self, forKey: "topics")?.map(\.domain) ?? [],
      tags: Array(container.decode([DTO<TagTransformer>].self, forKey: "tags").map(\.domain).uniqued())
    )
  }
}

// MARK: - AssetDetailTransformer.ExifTransformer

extension AssetDetailTransformer {
  struct ExifTransformer: DataTransformer {
    static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> AssetDetail.Exif {
      try AssetDetail.Exif(
        brand: container.decodeIfPresent(String.self, forKey: "make"),
        model: container.decodeIfPresent(String.self, forKey: "model"),
        name: container.decodeIfPresent(String.self, forKey: "name"),
        exposure: container.decodeIfPresent(String.self, forKey: "exposure_time"),
        aperture: container.decodeIfPresent(String.self, forKey: "aperture"),
        focalLength: container.decodeIfPresent(String.self, forKey: "focal_length"),
        iso: container.decodeIfPresent(Int.self, forKey: "iso")
      )
    }
  }

  struct LocationTransformer: DataTransformer {
    static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> AssetDetail.Location {
      try AssetDetail.Location(
        name: container.decode(String.self, forKey: "name"),
        city: container.decodeIfPresent(String.self, forKey: "city"),
        country: container.decode(String.self, forKey: "country"),
        position: container.decodeIfPresent(DTO<CoordinateTransformer>.self, forKey: "position")?.domain
      )
    }
  }

  struct CoordinateTransformer: DataTransformer {
    static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> (latitude: Double, longitude: Double)? {
      let latitude = try container.decodeIfPresent(Double.self, forKey: "latitude") ?? 0
      let longitude = try container.decodeIfPresent(Double.self, forKey: "longitude") ?? 0
      guard latitude != .zero, longitude != .zero else {
        return nil
      }
      return (latitude, longitude)
    }
  }

  struct TopicTransformer: DataTransformer {
    static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> AssetDetail.Topic {
      try AssetDetail.Topic(
        id: container.decode(String.self, forKey: "id"),
        title: container.decode(String.self, forKey: "title"),
        slug: container.decode(String.self, forKey: "slug"),
        visibility: container.decode(String.self, forKey: "visibility")
      )
    }
  }

  struct TagTransformer: DataTransformer {
    static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> AssetDetail.Tag {
      try AssetDetail.Tag(
        type: container.decode(String.self, forKey: "type"),
        title: container.decode(String.self, forKey: "title")
      )
    }
  }
}

// MARK: - AssetCollectionTransformer

struct AssetCollectionTransformer: DataTransformer {
  static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> AssetCollection {
    try AssetCollection(
      id: container.decode(String.self, forKey: "id"),
      shareKey: container.decode(String.self, forKey: "share_key"),
      updatedAt: container.decode(Date.self, forKey: "updated_at"),
      title: container.decode(String.self, forKey: "title"),
      imageURLs: container.decode([DTO<ImageURLTransformer>].self, forKey: "preview_photos").map(\.domain),
      totalImages: container.decode(Int.self, forKey: "total_photos"),
      user: container.decode(DTO<UserTransformer>.self, forKey: "user").domain,
      shareLink: container.decode(DTO<ShareLinkTransformer>.self, forKey: "links").domain
    )
  }
}

// MARK: - TopicTransformer

struct TopicTransformer: DataTransformer {
  static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> Topic {
    try Topic(
      id: container.decode(String.self, forKey: "id"),
      slug: container.decode(String.self, forKey: "slug"),
      visibility: container.decode(DTO<VisibilityTransformer>.self, forKey: "visibility").domain,
      owners: container.decode([DTO<UserTransformer>].self, forKey: "owners").map(\.domain),
      title: container.decode(String.self, forKey: "title"),
      description: container.decode(String.self, forKey: "description"),
      mediaTypes: Set(container.decode([DTO<MediaTypeTransformer>].self, forKey: "media_types").map(\.domain)),
      coverImage: container.decode(DTO<AssetTransformer>.self, forKey: "cover_photo").domain,
      imageCount: container.decode(Int.self, forKey: "total_photos"),
      shareLink: container.decode(DTO<ShareLinkTransformer>.self, forKey: "links").domain
    )
  }
}

// MARK: - TopicTransformer.VisibilityTransformer

extension TopicTransformer {
  struct VisibilityTransformer: DataTransformer {
    typealias Output = Topic.Visibility
    typealias Container = any SingleValueDecodingContainer
  }
}

// MARK: - CategoryTransformer

struct CategoryTransformer: DataTransformer {
  typealias Category = ResplashEntities.Category // (Fix 'Category' is ambiguous for type lookup in this context, Foundation.Category)

  static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> Category {
    try Category(
      id: UUID(),
      slug: container.decode(String.self, forKey: "slug"),
      title: container.decode(String.self, forKey: "title"),
      items: container.decode([DTO<ItemTransformer>].self, forKey: "children").map(\.domain)
    )
  }
}

// MARK: - CategoryTransformer.ItemTransformer

extension CategoryTransformer {
  struct ItemTransformer: DataTransformer {
    static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> Category.Item {
      try Category.Item(
        id: UUID(),
        slug: container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "ancestry")
          .nestedContainer(keyedBy: StringCodingKey.self, forKey: "subcategory")
          .decode(String.self, forKey: "slug"),
        redirect: container.decodeIfPresent(String.self, forKey: "redirect"),
        title: container.decode(String.self, forKey: "title"),
        subtitle: container.decode(String.self, forKey: "subtitle"),
        imageCount: (container.decode(Int.self, forKey: "photos_count") + 99) / 100 * 100, // round up
        coverImageURL: container.decode(DTO<ImageURLTransformer>.self, forKey: "cover_photo").domain
      )
    }
  }
}

// MARK: - TrendTransformer

struct TrendTransformer: DataTransformer {
  static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> Trend {
    try Trend(
      title: container.decode(String.self, forKey: "category"),
      demand: container.decode(DTO<DemandTransformer>.self, forKey: "demand").domain,
      thumbnailURL: container.decode(DTO<ImageURLTransformer>.self, forKey: "thumb").domain,
      growth: container.decode(Int.self, forKey: "growth"),
      results: container.decode(Int.self, forKey: "results"),
      searchViews: container.decode(Int.self, forKey: "search_views"),
      keywords: container.decode([DTO<KeywordTransformer>].self, forKey: "top_keywords").map(\.domain)
    )
  }
}

// MARK: - TrendTransformer.DemandTransformer

extension TrendTransformer {
  struct DemandTransformer: DataTransformer {
    typealias Output = Trend.Demand
    typealias Container = any SingleValueDecodingContainer
  }
}

// MARK: - TrendTransformer.KeywordTransformer

extension TrendTransformer {
  struct KeywordTransformer: DataTransformer {
    static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> Trend.Keyword {
      try Trend.Keyword(
        title: container.decode(String.self, forKey: "keyword"),
        demand: container.decode(DTO<DemandTransformer>.self, forKey: "demand").domain,
        thumbnailURL: container.decode(DTO<ImageURLTransformer>.self, forKey: "thumb").domain,
        growth: container.decode(Int.self, forKey: "growth"),
        results: container.decode(Int.self, forKey: "results"),
        searchViews: container.decode(Int.self, forKey: "search_views")
      )
    }
  }
}

// MARK: - SearchMetaTransformer

struct SearchMetaTransformer: DataTransformer {
  static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> SearchMeta {
    try SearchMeta(
      input: container.decode(String.self, forKey: "input"),
      photos: container.decode(Int.self, forKey: "photos"),
      illustrations: container.decode(Int.self, forKey: "illustrations"),
      collections: container.decode(Int.self, forKey: "collections"),
      users: container.decode(Int.self, forKey: "users"),
      relatedSearches: container.decode([DTO<RelatedSearchTransformer>].self, forKey: "related_searches").map(\.domain)
    )
  }
}

// MARK: - SearchMetaTransformer.RelatedSearchTransformer

extension SearchMetaTransformer {
  struct RelatedSearchTransformer: DataTransformer {
    static func transform(from container: KeyedDecodingContainer<StringCodingKey>) throws -> String {
      try container.decode(String.self, forKey: "title")
    }
  }
}
