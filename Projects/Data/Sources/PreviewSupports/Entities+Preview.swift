//
//  Entities+Preview.swift
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

#if DEBUG

import Foundation
import ResplashEntities

// MARK: - Unsplash.Image

extension Unsplash.Image {
  public static let preview1 = Unsplash.Image(
    id: "S84pCIjiEC4",
    slug: "glacial-lake-and-mountains-under-blue-sky-S84pCIjiEC4",
    createdAt: .now,
    updatedAt: .now,
    type: .photo,
    isPremium: false,
    description: "Glacial lake and mountains under blue sky",
    likes: 4920,
    width: 4032,
    height: 3024,
    color: "#0c73c0",
    url: Unsplash.ImageURL(
      raw: URL(string: "https://images.unsplash.com/photo-1571502297375-0fe3ea2d1d48?ixid=M3wxMjA3fDB8MXxzZWFyY2h8MjN8fCVFRCU5OCVCOCVFQyU4OCU5OHxlbnwwfHx8fDE3NjYwMzI3MDR8MA&ixlib=rb-4.1.0")!,
      full: URL(string: "https://images.unsplash.com/photo-1571502297375-0fe3ea2d1d48?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxMjA3fDB8MXxzZWFyY2h8MjN8fCVFRCU5OCVCOCVFQyU4OCU5OHxlbnwwfHx8fDE3NjYwMzI3MDR8MA&ixlib=rb-4.1.0&q=85")!,
      s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1571502297375-0fe3ea2d1d48")!
    ),
    user: .preview1,
    shareLink: URL(string: "https://unsplash.com/photos/glacial-lake-and-mountains-under-blue-sky-S84pCIjiEC4")!
  )

  public static let preview2 = Unsplash.Image(
    id: "VKEtwmKulIM",
    slug: "a-blue-and-yellow-pattern-with-squares-and-squares-VKEtwmKulIM",
    createdAt: .now,
    updatedAt: .now,
    type: .illustration,
    isPremium: false,
    description: "A blue and yellow pattern with squares and squares",
    likes: 4920,
    width: 1500,
    height: 1500,
    color: "#f3f3d9",
    url: Unsplash.ImageURL(
      raw: URL(string: "https://plus.unsplash.com/premium_vector-1719881386517-fb92d4c3680b?ixid=M3wxMjA3fDB8MXxzZWFyY2h8M3x8c3F1YXJlfGVufDB8fHx8MTc2NjAzMTI0MXww&ixlib=rb-4.1.0")!,
      full: URL(string: "https://plus.unsplash.com/premium_vector-1719881386517-fb92d4c3680b?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxMjA3fDB8MXxzZWFyY2h8M3x8c3F1YXJlfGVufDB8fHx8MTc2NjAzMTI0MXww&ixlib=rb-4.1.0&q=85")!,
      s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/unsplash-premium-photos-production/premium_vector-1719881386517-fb92d4c3680b")!
    ),
    user: .preview2,
    shareLink: URL(string: "https://unsplash.com/illustrations/a-blue-and-yellow-pattern-with-squares-and-squares-VKEtwmKulIM")!
  )
}

// MARK: - Unsplash.ImageCollection

extension Unsplash.ImageCollection {
  public static let preview1 = Unsplash.ImageCollection(
    id: "5BSAnZnIBpU",
    shareKey: "9aab0ad2c768d4be33049ab14006c35f",
    updatedAt: .now,
    title: "Soft Summer",
    imageURLs: [
      Unsplash.ImageURL(
        raw: URL(string: "https://plus.unsplash.com/premium_photo-1749544311043-3a6a0c8d54af?ixlib=rb-4.1.0")!,
        full: URL(string: "https://plus.unsplash.com/premium_photo-1749544311043-3a6a0c8d54af?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/unsplash-premium-photos-production/premium_photo-1749544311043-3a6a0c8d54af")!
      ),
      Unsplash.ImageURL(
        raw: URL(string: "https://plus.unsplash.com/premium_photo-1681190674797-062b73f23709?ixlib=rb-4.1.0")!,
        full: URL(string: "https://plus.unsplash.com/premium_photo-1681190674797-062b73f23709?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/unsplash-premium-photos-production/premium_photo-1681190674797-062b73f23709")!
      ),
      Unsplash.ImageURL(
        raw: URL(string: "https://plus.unsplash.com/premium_photo-1749544314290-26f458009fef?ixlib=rb-4.1.0")!,
        full: URL(string: "https://plus.unsplash.com/premium_photo-1749544314290-26f458009fef?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/unsplash-premium-photos-production/premium_photo-1749544314290-26f458009fef")!
      ),
      Unsplash.ImageURL(
        raw: URL(string: "https://plus.unsplash.com/premium_photo-1723934553084-2b0838d68e77?ixlib=rb-4.1.0")!,
        full: URL(string: "https://plus.unsplash.com/premium_photo-1723934553084-2b0838d68e77?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/unsplash-premium-photos-production/premium_photo-1723934553084-2b0838d68e77")!
      )
    ],
    totalImages: 50,
    user: .preview1,
    shareLink: URL(string: "https://unsplash.com/@unsplashplus")!
  )

  public static let preview2 = Unsplash.ImageCollection(
    id: "8GSGxHRK4qE",
    shareKey: "8d026a3765eda6ebb4ef3b930a44a9a4",
    updatedAt: .now,
    title: "lake",
    imageURLs: [
      Unsplash.ImageURL(
        raw: URL(string: "https://images.unsplash.com/photo-1761880619787-56285c7f5f1f?ixlib=rb-4.1.0")!,
        full: URL(string: "https://images.unsplash.com/photo-1761880619787-56285c7f5f1f?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1761880619787-56285c7f5f1f")!
      ),
      Unsplash.ImageURL(
        raw: URL(string: "https://plus.unsplash.com/premium_photo-1757100707921-070878fe3796?ixlib=rb-4.1.0")!,
        full: URL(string: "https://plus.unsplash.com/premium_photo-1757100707921-070878fe3796?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/unsplash-premium-photos-production/premium_photo-1757100707921-070878fe3796")!
      ),
      Unsplash.ImageURL(
        raw: URL(string: "https://images.unsplash.com/photo-1761671263798-758aac2b4d68?ixlib=rb-4.1.0")!,
        full: URL(string: "https://images.unsplash.com/photo-1761671263798-758aac2b4d68?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1761671263798-758aac2b4d68")!
      ),
      Unsplash.ImageURL(
        raw: URL(string: "https://images.unsplash.com/photo-1752035682784-b482b6904c13?ixlib=rb-4.1.0")!,
        full: URL(string: "https://images.unsplash.com/photo-1752035682784-b482b6904c13?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1752035682784-b482b6904c13")!
      )
    ],
    totalImages: 134,
    user: .preview2,
    shareLink: URL(string: "https://unsplash.com/@unsplashplus")!
  )
}

// MARK: - Unsplash.ImageDetail

extension Unsplash.ImageDetail {
  public static let preview1 = Unsplash.ImageDetail(
    image: .preview1,
    views: 1386704,
    downloads: 18637,
    exif: Unsplash.ImageDetail.Exif(
      brand: "Apple",
      model: "iPhone 17",
      name: "Apple, iPhone 17",
      exposure: "1/2500",
      aperture: "1.8",
      focalLength: "4.0",
      iso: 20
    ),
    location: Unsplash.ImageDetail.Location(
      name: "Seebensee, Österreich",
      city: nil,
      country: "Österreich",
      position: (47.3688148, 10.934934),
    ),
    topics: [],
    tags: [
      Unsplash.ImageDetail.Tag(type: "search", title: "mountains"),
      Unsplash.ImageDetail.Tag(type: "search", title: "hiking"),
      Unsplash.ImageDetail.Tag(type: "search", title: "lake"),
      Unsplash.ImageDetail.Tag(type: "search", title: "alps"),
      Unsplash.ImageDetail.Tag(type: "search", title: "see"),
      Unsplash.ImageDetail.Tag(type: "search", title: "wanderlust"),
      Unsplash.ImageDetail.Tag(type: "search", title: "zugspitze"),
      Unsplash.ImageDetail.Tag(type: "search", title: "alpen"),
      Unsplash.ImageDetail.Tag(type: "search", title: "berge"),
      Unsplash.ImageDetail.Tag(type: "search", title: "wandern"),
      Unsplash.ImageDetail.Tag(type: "search", title: "blue")
    ]
  )
}

// MARK: - Unsplash.Category

extension Unsplash.Category {
  public static let preview = Unsplash.Category(
    id: UUID(),
    slug: "stock",
    title: "Stock Photos & Images",
    items: [.preview]
  )
}

// MARK: - Unsplash.Category.Item

extension Unsplash.Category.Item {
  public static let preview = Unsplash.Category.Item(
    id: UUID(),
    slug: "royalty-free",
    redirect: nil,
    title: "Royalty Free Images",
    subtitle: "309,100+ Stocks and Images",
    imageCount: 309099,
    coverImageURL: Unsplash.ImageURL(
      raw: URL(string: "https://images.unsplash.com/photo-1612899326681-66508905b4ce?ixlib=rb-4.1.0")!,
      full: URL(string: "https://images.unsplash.com/photo-1612899326681-66508905b4ce?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
      s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1612899326681-66508905b4ce")!
    )
  )
}

// MARK: - Unsplash.Topic

extension Unsplash.Topic {
  public static let preview = Unsplash.Topic(
    id: "bo8jQKT",
    slug: "wallpapers",
    visibility: .featured,
    owners: [.preview1],
    title: "Wallpapers",
    description: "From epic drone shots to inspiring moments in nature — enjoy the best background for your desktop or mobile.",
    mediaTypes: [.photo],
    coverImage: .preview1,
    imageCount: 16519,
    shareLink: URL(string: "https://unsplash.com/ko/t/wallpapers")!
  )
}

// MARK: - Unsplash.Trend

extension Unsplash.Trend {
  public static let preview = Unsplash.Trend(
    title: "new zealand",
    demand: .high,
    thumbnailURL: Unsplash.ImageURL(
      raw: URL(string: "https://images.unsplash.com/photo-1465056836041-7f43ac27dcb5?ixlib=rb-4.1.0")!,
      full: URL(string: "https://images.unsplash.com/photo-1465056836041-7f43ac27dcb5?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
      s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1465056836041-7f43ac27dcb5")!
    ),
    growth: 1161,
    results: 684238,
    searchViews: 3545366,
    keywords: [
      Unsplash.Trend.Keyword(
        title: "auckland",
        demand: .high,
        thumbnailURL: Unsplash.ImageURL(
          raw: URL(string: "https://images.unsplash.com/photo-1595125990323-885cec5217ff?ixlib=rb-4.1.0")!,
          full: URL(string: "https://images.unsplash.com/photo-1595125990323-885cec5217ff?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
          s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1595125990323-885cec5217ff")!
        ),
        growth: 4300,
        results: 37782,
        searchViews: 252555
      ),
      Unsplash.Trend.Keyword(
        title: "queenstown",
        demand: .medium,
        thumbnailURL: Unsplash.ImageURL(
          raw: URL(string: "https://images.unsplash.com/photo-1600466403153-50193d187dde?ixlib=rb-4.1.0")!,
          full: URL(string: "https://images.unsplash.com/photo-1600466403153-50193d187dde?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
          s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1600466403153-50193d187dde")!
        ),
        growth: 25,
        results: 472,
        searchViews: 87509
      ),
      Unsplash.Trend.Keyword(
        title: "wellington",
        demand: .medium,
        thumbnailURL: Unsplash.ImageURL(
          raw: URL(string: "https://images.unsplash.com/photo-1589871973318-9ca1258faa5d?ixlib=rb-4.1.0")!,
          full: URL(string: "https://images.unsplash.com/photo-1589871973318-9ca1258faa5d?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
          s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1589871973318-9ca1258faa5d")!
        ),
        growth: -77,
        results: 4161,
        searchViews: 41931
      )
    ]
  )
}

// MARK: - Unsplash.User

extension Unsplash.User {
  public static let preview1 = Unsplash.User(
    id: "2tXKaPcv9BI",
    userId: "marekpiwnicki",
    updatedAt: .now,
    forHire: true,
    name: "Marek Piwnicki",
    bio: "Hey! I have 3B+ views and 22M+ dwnl here.If my work has helped or inspired you, please consider supporting me (patreon.com/MarekPiwnicki or ko-fi.com/marekpiwnicki). Every bit helps me continue creating and sharing my photos for free. Thank you! ❤️",
    location: "Gdynia | Poland",
    profileImageURL: Unsplash.User.ProfileImageURL(
      small: URL(string: "https://images.unsplash.com/profile-1604758536753-68fd6f23aaf7image?ixlib=rb-4.1.0&crop=faces&fit=crop&w=32&h=32")!,
      medium: URL(string: "https://images.unsplash.com/profile-1604758536753-68fd6f23aaf7image?ixlib=rb-4.1.0&crop=faces&fit=crop&w=64&h=64")!,
      large: URL(string: "https://images.unsplash.com/profile-1604758536753-68fd6f23aaf7image?ixlib=rb-4.1.0&crop=faces&fit=crop&w=128&h=128")!
    ),
    totalLikes: 27_920,
    totalCollections: 2582,
    totalPhotos: 194_501,
    totalIllustrations: 4958,
    socials: [
      .instagram("marekpiwnicki"),
      .twitter("piensaenpixel"),
      .paypal("marpiwnicki@gmail.com"),
      .portfolio(URL(string: "https://marpiwnicki.github.io")!)
    ],
    shareLink: URL(string: "https://unsplash.com/@marekpiwnicki")!,
    imageURLs: [
      Unsplash.ImageURL(
        raw: URL(string: "https://images.unsplash.com/photo-1610204969792-31940287e22d?ixlib=rb-4.1.0")!,
        full: URL(string: "https://images.unsplash.com/photo-1610204969792-31940287e22d?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1610204969792-31940287e22d")!
      ),
      Unsplash.ImageURL(
        raw: URL(string: "https://images.unsplash.com/photo-1606245766933-b194a66b0380?ixlib=rb-4.1.0")!,
        full: URL(string: "https://images.unsplash.com/photo-1606245766933-b194a66b0380?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1606245766933-b194a66b0380")!
      ),
      Unsplash.ImageURL(
        raw: URL(string: "https://images.unsplash.com/photo-1605904266472-c5be8939cdb6?ixlib=rb-4.1.0")!,
        full: URL(string: "https://images.unsplash.com/photo-1605904266472-c5be8939cdb6?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1605904266472-c5be8939cdb6")!
      )
    ]
  )

  public static let preview2 = Unsplash.User(
    id: "qHyQcK243W0",
    userId: "calebbosman17",
    updatedAt: .now,
    forHire: true,
    name: "Dutch Artisan",
    bio: "Hi, I am Caleb Bosman. I like taking photos. unsplash is where I put my 2nd rate photos. You can find my better photos on Adobe Behance @calebbosman1.",
    location: "Hume Lake",
    profileImageURL: Unsplash.User.ProfileImageURL(
      small: URL(string: "https://images.unsplash.com/profile-1714690147535-205a06abb9adimage?ixlib=rb-4.1.0&crop=faces&fit=crop&w=32&h=32")!,
      medium: URL(string: "https://images.unsplash.com/profile-1714690147535-205a06abb9adimage?ixlib=rb-4.1.0&crop=faces&fit=crop&w=64&h=64")!,
      large: URL(string: "https://images.unsplash.com/profile-1714690147535-205a06abb9adimage?ixlib=rb-4.1.0&crop=faces&fit=crop&w=128&h=128")!
    ),
    totalLikes: 7920,
    totalCollections: 582,
    totalPhotos: 19501,
    totalIllustrations: 958,
    socials: [
      .portfolio(URL(string: "https://www.behance.net/calebbosman1")!)
    ],
    shareLink: URL(string: "https://unsplash.com/ko/@calebbosman17")!,
    imageURLs: [
      Unsplash.ImageURL(
        raw: URL(string: "https://images.unsplash.com/photo-1714436457165-b1eaac55bec8?ixlib=rb-4.1.0")!,
        full: URL(string: "https://images.unsplash.com/photo-1714436457165-b1eaac55bec8?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1714436457165-b1eaac55bec8")!
      ),
      Unsplash.ImageURL(
        raw: URL(string: "https://images.unsplash.com/photo-1716009434314-3eb790848e77?ixlib=rb-4.1.0")!,
        full: URL(string: "https://images.unsplash.com/photo-1716009434314-3eb790848e77?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1716009434314-3eb790848e77")!
      ),
      Unsplash.ImageURL(
        raw: URL(string: "https://images.unsplash.com/photo-1715141184840-20b3deb30584?ixlib=rb-4.1.0")!,
        full: URL(string: "https://images.unsplash.com/photo-1715141184840-20b3deb30584?ixlib=rb-4.1.0&q=85&fm=jpg&crop=entropy&cs=srgb")!,
        s3: URL(string: "https://s3.us-west-2.amazonaws.com/images.unsplash.com/small/photo-1715141184840-20b3deb30584")!
      )
    ]
  )
}

#endif
