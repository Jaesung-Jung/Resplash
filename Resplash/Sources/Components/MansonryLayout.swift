//
//  MansonryLayout.swift
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

struct MansonryStack<Data: RandomAccessCollection, ID: Hashable, Content: View>: View where Data.Index == Int {
  let data: Data
  let id: KeyPath<Data.Element, ID>
  let columns: Int
  let spacing: CGFloat
  let content: (Data.Element) -> Content

  init(_ data: Data, id: KeyPath<Data.Element, ID>, columns: Int, spacing: CGFloat = 0, @ViewBuilder content: @escaping (Data.Element) -> Content) {
    self.data = data
    self.id = id
    self.columns = columns
    self.spacing = spacing
    self.content = content
  }

  init(_ data: Data, columns: Int, spacing: CGFloat = 0, @ViewBuilder content: @escaping (Data.Element) -> Content) where Data.Element: Identifiable, ID == Data.Element.ID {
    self.data = data
    self.id = \.id
    self.columns = columns
    self.spacing = spacing
    self.content = content
  }

  var body: some View {
//    GeometryReader { proxy in
//      HStack(alignment: .top, spacing: spacing) {
//        ForEach(0..<columns, id: \.self) { _ in
//          LazyVStack(spacing: spacing) {
//          }
//        }
//      }
//      .frame(width: proxy.size.width)
//      .onAppear {
//        let itemWidth = (proxy.size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
//        let columnHeights = Array(repeating: CGFloat(0), count: columns)
//        let columnX
//      }
//    }
  }
}
