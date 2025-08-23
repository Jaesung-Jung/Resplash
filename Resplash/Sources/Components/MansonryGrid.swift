//
//  MansonryGrid.swift
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

import SwiftUI

struct MansonryGrid<Data: RandomAccessCollection & Sendable, Content: View>: View where Data.Element: Identifiable & Hashable {
  @State var buckets: [[Data.Element]] = []

  var id: Int {
    var hasher = Hasher()
    hasher.combine(columns)
    hasher.combine(spacing.bitPattern)
    if let first = data.first, let last = data.last {
      hasher.combine(first.id)
      hasher.combine(last.id)
    }
    return hasher.finalize()
  }

  let data: Data
  let columns: Int
  let spacing: CGFloat

  @ViewBuilder let content: (Data.Element) -> Content
  let size: @Sendable (Data.Element) -> CGSize

  init(_ data: Data, columns: Int, spacing: CGFloat = 0, content: @escaping (Data.Element) -> Content, size: @Sendable @escaping (Data.Element) -> CGSize) {
    self.data = data
    self.columns = columns
    self.spacing = spacing
    self.content = content
    self.size = size
  }

  var body: some View {
    HStack(alignment: .top, spacing: spacing) {
      ForEach(0..<columns, id: \.self) { column in
        LazyVStack(spacing: spacing) {
          if let bucket = buckets[safe: column] {
            ForEach(bucket) { item in
              let size = size(item)
              content(item)
                .aspectRatio(CGSize(width: 1, height: size.height / size.width), contentMode: .fill)
            }
          }
        }
      }
    }
    .task(id: id) {
      buckets = await distribute(data, columns: columns, size: size)
    }
  }

  @concurrent
  func distribute(_ data: Data, columns: Int, size: (Data.Element) -> CGSize) async -> [[Data.Element]] {
    guard columns > 1 else {
      return [Array(data)]
    }
    var buckets: [[Data.Element]] = Array(repeating: [], count: columns)
    var heights: [CGFloat] = Array(repeating: 0, count: columns)
    for element in data {
      let itemSize = size(element)
      let weight = itemSize.width > 0 ? (itemSize.height / itemSize.width) : 1
      if let index = heights.indices.min(by: { heights[$0] < heights[$1] }) {
        buckets[index].append(element)
        heights[index] += weight
      }
    }
    return buckets
  }
}
