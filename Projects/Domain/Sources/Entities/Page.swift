//
//  Page.swift
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

public struct Page<Item> {
  public typealias Index = [Item].Index
  public typealias Iterator = [Item].Iterator

  public let page: Int
  public let isAtEnd: Bool
  public let items: [Item]

  public init(page: Int, pageSize: Int, items: [Item]) {
    self.page = page
    self.isAtEnd = items.count < pageSize
    self.items = items
  }

  public init<S: Sequence>(page: Int, pageSize: Int, items: S) where S.Element == Item {
    let array = Array(items)
    self.page = page
    self.isAtEnd = array.count < pageSize
    self.items = array
  }

  public init(page: Int, isAtEnd: Bool, items: [Item]) {
    self.page = page
    self.isAtEnd = isAtEnd
    self.items = items
  }

  public init<S: Sequence>(page: Int, isAtEnd: Bool, items: S) where S.Element == Item {
    self.page = page
    self.isAtEnd = isAtEnd
    self.items = Array(items)
  }
}

extension Page: Collection {
  @inlinable public var startIndex: Index { items.startIndex }
  @inlinable public var endIndex: Index { items.endIndex }

  @inlinable public func index(after i: Index) -> Index { items.index(after: i) }
  @inlinable public subscript(position: Index) -> Item { items[position] }

  @inlinable public var count: Int { items.count }

  @inlinable public func makeIterator() -> Iterator {
    items.makeIterator()
  }
}

extension Page: Equatable where Item: Equatable {
}

extension Page: Sendable where Item: Sendable {
}
