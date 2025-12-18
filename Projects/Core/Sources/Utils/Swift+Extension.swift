//
//  Swift+Extension.swift
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

// MARK: - Sequence

extension Sequence {
  /// Returns a sorted array of elements using a key path to compare values.
  ///
  /// - Parameter keyPath: The key path to the property used for sorting.
  /// - Returns: A sorted array of the sequence's elements.
  @inlinable public func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    sorted(by: keyPath, by: <)
  }

  /// Returns a sorted array of elements using a key path and a custom comparator.
  ///
  /// - Parameters:
  ///   - keyPath: The key path to the property used for sorting.
  ///   - areInIncreasingOrder: A function that compares two property values and returns `true` if they are in the desired order.
  /// - Returns: A sorted array of the sequence's elements.
  @inlinable public func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>, by areInIncreasingOrder: (T, T) -> Bool) -> [Element] {
    sorted { areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath]) }
  }
}

// MARK: - Collection

extension Collection {
  /// Safely returns the element at the specified position, or `nil` if the index is out of bounds.
  ///
  /// - Parameter position: The index of the element.
  /// - Returns: The element at the specified index if it exists, otherwise `nil`.
  @inlinable public subscript(safe position: Index) -> Element? {
    indices.contains(position) ? self[position] : nil
  }
}
