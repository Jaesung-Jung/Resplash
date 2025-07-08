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
