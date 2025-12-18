import Testing
@testable import ResplashUtils

// MARK: - SequenceExtensionTests

@Suite
struct SequenceExtensionTests {
  @Test
  func sortsByKeyPathAscendingAndCustomComparator() {
    struct Person {
      let name: String
      let age: Int
    }

    let people = [
      Person(name: "Charlie", age: 35),
      Person(name: "Alice", age: 30),
      Person(name: "Bob", age: 25)
    ]

    let sortedByName = people.sorted(by: \.name)
    #expect(sortedByName.map(\.name) == ["Alice", "Bob", "Charlie"])

    let sortedByAgeDescending = people.sorted(by: \.age, by: >)
    #expect(sortedByAgeDescending.map(\.age) == [35, 30, 25])
  }
}

// MARK: - CollectionExtensionTests

@Suite
struct CollectionExtensionTests {
  @Test
  func returnsElementForValidIndexAndNilForOutOfBoundsIndex() {
    let array = [1, 2, 3]
    #expect(array[safe: array.startIndex] == 1)
    #expect(array[safe: array.index(after: array.startIndex)] == 2)
    #expect(array[safe: array.index(before: array.endIndex)] == 3)
    #expect(array[safe: array.endIndex] == nil)
    #expect(array[safe: array.index(after: array.endIndex)] == nil)
  }
}
