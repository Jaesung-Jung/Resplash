//
//  Page.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

struct Page<Base: Collection> {
  typealias Element = Base.Element
  typealias Index = Base.Index
  typealias Iterator = Base.Iterator

  let page: Int
  let isAtEnd: Bool
  let items: Base
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
