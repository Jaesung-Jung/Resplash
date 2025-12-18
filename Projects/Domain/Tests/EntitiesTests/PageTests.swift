import Testing
@testable import ResplashEntities

@Suite
struct PageTests {
  @Test
  func storesMetadataAndItems() {
    let items = [1, 2, 3]
    let page = Page(page: 2, isAtEnd: false, items: items)

    #expect(page.page == 2)
    #expect(page.isAtEnd == false)
    #expect(Array(page.items) == items)
  }

  @Test
  func exposesCollectionIndicesFromBaseCollection() {
    let items = [10, 20, 30]
    let page = Page(page: 0, isAtEnd: true, items: items)

    #expect(page.startIndex == items.startIndex)
    #expect(page.endIndex == items.endIndex)
  }

  @Test
  func forwardsIndexAfterToBaseCollection() {
    let items = [10, 20, 30]
    let page = Page(page: 0, isAtEnd: false, items: items)

    let i0 = page.startIndex
    let i1 = page.index(after: i0)
    let i2 = page.index(after: i1)

    #expect(page[i0] == 10)
    #expect(page[i1] == 20)
    #expect(page[i2] == 30)
  }

  @Test
  func forwardsSubscriptToBaseCollection() {
    let items = [1, 2, 3, 4]
    let page = Page(page: 1, isAtEnd: false, items: items)

    #expect(page[page.startIndex] == 1)
    #expect(page[items.index(after: items.startIndex)] == 2)
    #expect(page[items.index(before: items.endIndex)] == 4)
  }

  @Test
  func forwardsCountToBaseCollection() {
    let items = Array(0..<7)
    let page = Page(page: 3, isAtEnd: false, items: items)

    #expect(page.count == items.count)
  }

  @Test
  func iteratesInSameOrderAsBaseCollection() {
    let items = ["A", "B", "C"]
    let page = Page(page: 0, isAtEnd: false, items: items)

    let iterated = Array(page)
    #expect(iterated == items)
  }

  @Test
  func worksWithNonZeroBasedIndicesCollections() {
    // ArraySlice has indices that typically start at the slice's lowerBound.
    let base = Array(0..<10)
    let slice = base[3..<7] // elements: 3,4,5,6
    let page = Page(page: 0, isAtEnd: false, items: slice)

    #expect(page.count == slice.count)
    #expect(page.startIndex == slice.startIndex)
    #expect(page.endIndex == slice.endIndex)
    #expect(Array(page) == Array(slice))
  }
}
