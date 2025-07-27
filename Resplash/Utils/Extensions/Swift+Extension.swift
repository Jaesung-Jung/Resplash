//
//  Swift+Extension.swift
//  Resplash
//
//  Created by 정재성 on 7/7/25.
//

// MARK: - Collection (Safe Access)

extension Collection {
  @inlinable subscript(safe position: Index) -> Element? {
    indices.contains(position) ? self[position] : nil
  }
}

extension Array {
  @inlinable func appending(_ newElement: Element) -> [Element] {
    var mutable = self
    mutable.append(newElement)
    return mutable
  }

  @inlinable func appending<S: Sequence>(contentsOf newElements: S) -> [Element] where S.Element == Element {
    var mutable = self
    mutable.append(contentsOf: newElements)
    return mutable
  }
}
