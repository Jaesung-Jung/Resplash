//
//  Image.swift
//  Resplash
//
//  Created by 정재성 on 7/14/25.
//

import Algorithms

@dynamicMemberLookup
struct ImageAssetDetail {
  let asset: ImageAsset
  let views: Int
  let downloads: Int
  let exif: Exif?
  let location: Location?
  let topics: [Topic]
  let tags: [Tag]

  @inlinable subscript<T>(dynamicMember keyPath: KeyPath<ImageAsset, T>) -> T {
    asset[keyPath: keyPath]
  }
}

// MARK: - ImageAssetDetail (Hashable)

extension ImageAssetDetail: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(asset)
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.asset == rhs.asset
  }
}

// MARK: - ImageAssetDetail (Decodable)

extension ImageAssetDetail: Decodable {
  init(from decoder: any Decoder) throws {
    self.asset = try ImageAsset(from: decoder)
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.views = try container.decode(Int.self, forKey: "views")
    self.downloads = try container.decode(Int.self, forKey: "downloads")
    self.exif = try? container.decode(Exif.self, forKey: "exif")
    self.location = try? container.decode(Location.self, forKey: "location")
    self.topics = (try? container.decode([Topic].self, forKey: "topics")) ?? []
    self.tags = Array(try container.decode([Tag].self, forKey: "tags").uniqued())
  }
}

// MARK: - ImageAssetDetail.Exif

extension ImageAssetDetail {
  struct Exif: Decodable {
    let brand: String?
    let model: String?
    let name: String?
    let exposure: String?
    let aperture: String?
    let focalLength: String?
    let iso: Int?

    enum CodingKeys: String, CodingKey {
      case brand = "make"
      case model
      case name
      case exposure = "exposure_time"
      case aperture = "aperture"
      case focalLength = "focal_length"
      case iso
    }
  }
}

// MARK: - ImageAssetDetail.Location

extension ImageAssetDetail {
  struct Location {
    let name: String
    let city: String?
    let country: String
    let position: (latitude: Double, longitude: Double)?
  }
}

// MARK: - ImageAssetDetail.Topic

extension ImageAssetDetail {
  struct Topic: Decodable {
    let id: String
    let title: String
    let slub: String
    let visibility: String
  }
}

// MARK: - ImageAssetDetail.Tag

extension ImageAssetDetail {
  struct Tag: Decodable, Hashable {
    let type: String
    let title: String
  }
}

// MARK: - ImageAssetDetail.Location (Decodable)

extension ImageAssetDetail.Location: Decodable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: StringCodingKey.self)
    self.name = try container.decode(String.self, forKey: "name")
    self.city = try container.decodeIfPresent(String.self, forKey: "city")
    self.country = try container.decode(String.self, forKey: "country")
    let positionContainer = try container.nestedContainer(keyedBy: StringCodingKey.self, forKey: "position")
    let latitude = try positionContainer.decodeIfPresent(Double.self, forKey: "latitude") ?? 0
    let longitude = try positionContainer.decodeIfPresent(Double.self, forKey: "longitude") ?? 0
    if latitude != .zero, longitude != .zero {
      self.position = (latitude, longitude)
    } else {
      self.position = nil
    }
  }
}
