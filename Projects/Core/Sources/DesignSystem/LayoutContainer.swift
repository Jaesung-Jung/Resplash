//
//  LayoutContainer.swift
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

public struct LayoutContainer<Content: View>: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  let content: (LayoutEnvironment) -> Content

  public init(@ViewBuilder content: @escaping (LayoutEnvironment) -> Content) {
    self.content = content
  }

  public var body: some View {
    content(horizontalSizeClass == .regular ? .regularLayoutEnvironment() : .compactLayoutEnvironment())
  }
}

// MARK: - LayoutEnvironment

public struct LayoutEnvironment: Sendable {
  @usableFromInline
  let contentInsets: EdgeInsets

  @inlinable
  public func contentInsets(_ edges: Edge.Set) -> EdgeInsets {
    EdgeInsets(
      top: edges.contains(.top) ? contentInsets.top : 0,
      leading: edges.contains(.leading) ? contentInsets.leading : 0,
      bottom: edges.contains(.bottom) ? contentInsets.bottom : 0,
      trailing: edges.contains(.trailing) ? contentInsets.trailing : 0
    )
  }

  static func compactLayoutEnvironment() -> LayoutEnvironment {
    LayoutEnvironment(
      contentInsets: EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
    )
  }

  static func regularLayoutEnvironment() -> LayoutEnvironment {
    LayoutEnvironment(
      contentInsets: EdgeInsets(top: 0, leading: 40, bottom: 40, trailing: 40)
    )
  }
}
