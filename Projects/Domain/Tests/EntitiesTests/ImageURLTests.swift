import Foundation
import Testing
@testable import ResplashEntities

@Suite
struct ImageURLTests {
  @Test(arguments: [
    Unsplash.ImageURL.Size.fhd,
    Unsplash.ImageURL.Size.hd,
    Unsplash.ImageURL.Size.sd,
    Unsplash.ImageURL.Size.low
  ])
  func urlQueryTests(size: Unsplash.ImageURL.Size) throws {
    let imageURL = try Unsplash.ImageURL(
      raw: #require(URL(string: "https://image.raw.test")),
      full: #require(URL(string: "https://image.full.test")),
      s3: #require(URL(string: "https://image.s3.test"))
    )
    let url = try #require(imageURL.url(size))
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    #expect(components.url?.absoluteString.hasPrefix("https://image.raw.test") == true)

    let queryItems = try #require(components.queryItems)
    #expect(queryItems.first { $0.name == "crop" }?.value == "entropy")
    #expect(queryItems.first { $0.name == "fm" }?.value == "jpg")
    #expect(queryItems.first { $0.name == "q" }?.value == "\(size.quality)")
    #expect(queryItems.first { $0.name == "w" }?.value == "\(size.rawValue)")
  }
}
