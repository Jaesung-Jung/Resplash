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

struct Page<Base: Collection> {
  typealias Element = Base.Element
  typealias Index = Base.Index
  typealias Iterator = Base.Iterator

  let page: Int
  let isAtEnd: Bool
  let items: Base
}

// MARK: - Page (Sendable)

extension Page: Sendable where Base: Sendable {
}

// MARK: - Page (Collection)

extension Page: Collection {
  @inlinable var startIndex: Index { items.startIndex }
  @inlinable var endIndex: Index { items.endIndex }

  @inlinable func index(after i: Index) -> Index { items.index(after: i) }
  @inlinable subscript(position: Index) -> Element { items[position] }

  @inlinable var count: Int { items.count }

  @inlinable func makeIterator() -> Iterator {
    items.makeIterator()
  }
}
