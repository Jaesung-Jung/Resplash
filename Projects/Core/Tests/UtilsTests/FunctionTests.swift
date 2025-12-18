import Testing
@testable import ResplashUtils

// MARK: - ClampTests

@Suite
struct ClampFunctionTests {
  @Test
  func returnsValueWithinRange() {
    let value = 5
    let clampedValue = clamp(value, min: 0, max: 10)
    #expect(clampedValue == 5)
  }

  @Test
  func returnsMinWhenValueIsBelowRange() {
    let value = -5
    let clampedValue = clamp(value, min: 0, max: 10)
    #expect(clampedValue == 0)
  }

  @Test
  func returnsMaxWhenValueIsAboveRange() {
    let value = 15
    let clampedValue = clamp(value, min: 0, max: 10)
    #expect(clampedValue == 10)
  }

  @Test
  func returnsExactValueWhenMinEqualsMax() {
    let value = 5
    let clampedValue = clamp(value, min: 10, max: 10)
    #expect(clampedValue == 10)
  }

  @Test
  func clampsFloatingPointValue() {
    let value = 5.5
    let clampedValue = clamp(value, min: 0.0, max: 5.0)
    #expect(clampedValue == 5.0)
  }
}

// MARK: - CurryFunctionTests

@Suite
struct CurryFunctionTests {
  @Test
  func curriesTwoArgumentFunction() {
    func add(_ a: Int, _ b: Int) -> Int { a + b }
    let curriedAdd = curry(add)

    let result = curriedAdd(5)(10)
    #expect(result == 15)
  }

  @Test
  func curriesThreeArgumentFunction() {
    func multiply(_ a: Int, _ b: Int, _ c: Int) -> Int { a * b * c }
    let curriedMultiply = curry(multiply)

    let result = curriedMultiply(2)(3)(4)
    #expect(result == 24)
  }

  @Test
  func curriesFourArgumentFunction() {
    func sum(_ a: Int, _ b: Int, _ c: Int, _ d: Int) -> Int {
      a + b + c + d
    }
    let curriedSum = curry(sum)

    let result = curriedSum(1)(2)(3)(4)
    #expect(result == 10)
  }

  @Test
  func curriesFiveArgumentFunction() {
    func concatenate(
      _ a: String, _ b: String, _ c: String, _ d: String, _ e: String
    ) -> String {
      a + b + c + d + e
    }

    let curriedConcatenate = curry(concatenate)
    let result = curriedConcatenate("A")("B")("C")("D")("E")

    #expect(result == "ABCDE")
  }
}

// MARK: - MemoizeFunctionTests

@Suite
struct MemoizeFunctionTests {
  @Test
  func memoizesZeroArgumentFunction() {
    var counter = 0
    let memoized = memoize {
      counter += 1
      return "Result"
    }

    _ = memoized()
    _ = memoized()

    #expect(counter == 1)
  }

  @Test
  func memoizesSingleArgumentFunction() {
    var counter = 0
    let memoized = memoize { (value: Int) -> String in
      counter += 1
      return "Result \(value)"
    }

    _ = memoized(1)
    _ = memoized(1)
    _ = memoized(2)

    #expect(counter == 2)
  }

  @Test
  func memoizesTwoArgumentFunction() {
    var counter = 0
    let memoized = memoize { (a: Int, b: Int) -> String in
      counter += 1
      return "\(a + b)"
    }

    _ = memoized(1, 2)
    _ = memoized(1, 2)
    _ = memoized(3, 4)

    #expect(counter == 2)
  }

  @Test
  func memoizesThreeArgumentFunction() {
    var counter = 0
    let memoized = memoize { (a: Int, b: Int, c: Int) -> String in
      counter += 1
      return "\(a + b + c)"
    }

    _ = memoized(1, 2, 3)
    _ = memoized(1, 2, 3)
    _ = memoized(4, 5, 6)

    #expect(counter == 2)
  }

  @Test
  func memoizesFourArgumentFunction() {
    var counter = 0
    let memoized = memoize { (a: Int, b: Int, c: Int, d: Int) -> String in
      counter += 1
      return "\(a + b + c + d)"
    }

    _ = memoized(1, 2, 3, 4)
    _ = memoized(1, 2, 3, 4)
    _ = memoized(5, 6, 7, 8)

    #expect(counter == 2)
  }

  @Test
  func memoizesFiveArgumentFunction() {
    var counter = 0
    let memoized = memoize { (a: Int, b: Int, c: Int, d: Int, e: Int) -> String in
      counter += 1
      return "\(a + b + c + d + e)"
    }

    _ = memoized(1, 2, 3, 4, 5)
    _ = memoized(1, 2, 3, 4, 5)
    _ = memoized(6, 7, 8, 9, 10)

    #expect(counter == 2)
  }
}
