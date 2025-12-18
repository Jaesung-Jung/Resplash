import UIKit
import Testing
@testable import ResplashUtils

@Suite
struct UIImageResizeTests {
  /// Creates a test UIImage with the given color and size
  private func makeTestImage(color: UIColor, size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { ctx in
      color.setFill()
      ctx.fill(CGRect(origin: .zero, size: size))
    }
  }

  // MARK: - Tests

  @Test
  func resizesImageToExactTargetSize() throws {
    // Given
    let original = makeTestImage(color: .red, size: CGSize(width: 200, height: 100))
    let targetSize = CGSize(width: 80, height: 40)

    // When
    let resized = original.resize(to: targetSize)

    // Then
    let result = try #require(resized)
    #expect(result.size.width == targetSize.width)
    #expect(result.size.height == targetSize.height)
  }

  @Test
  func resizesImageToFitBoundsPreservingAspectRatioForWideImage() throws {
    // Given
    // 300×150 image resized into 100×100 bounds
    let original = makeTestImage(color: .blue, size: CGSize(width: 300, height: 150))
    let bounds = CGSize(width: 100, height: 100)

    // When
    let resized = original.resize(in: bounds)

    // Then
    let result = try #require(resized)
    #expect(result.size.width == 100)
    #expect(result.size.height == 50)
  }

  @Test
  func resizesImageToFitBoundsPreservingAspectRatioForTallImage() throws {
    // Given
    // 150×300 image resized into 100×100 bounds
    let original = makeTestImage(color: .green, size: CGSize(width: 150, height: 300))
    let bounds = CGSize(width: 100, height: 100)

    // When
    let resized = original.resize(in: bounds)

    // Then
    let result = try #require(resized)
    #expect(result.size.width == 50)
    #expect(result.size.height == 100)
  }

  @Test
  func appliesUniformScaleWhenImageAndBoundsHaveSameAspectRatio() throws {
    // Given
    // 400×200 image resized into 200×100 bounds
    let original = makeTestImage(color: .yellow, size: CGSize(width: 400, height: 200))
    let bounds = CGSize(width: 200, height: 100)

    // When
    let resized = original.resize(in: bounds)

    // Then
    let result = try #require(resized)
    #expect(result.size.width == 200)
    #expect(result.size.height == 100)
  }
}
