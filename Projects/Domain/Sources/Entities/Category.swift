//
//  Category.swift
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

import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct Category {
  public let id: UUID
  public let slug: String
  public let title: String
  public let items: [Item]
}

extension Category: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

extension Category: Identifiable {
}

extension Category: Sendable {
}

// MARK: - Category.Item

extension Category {
  @MemberwiseInit(.public)
  public struct Item {
    public let id: UUID
    public let slug: String
    public let redirect: String?

    public let title: String
    public let subtitle: String
    public let imageCount: Int
    public let coverImageURL: ImageURL

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
  }
}

extension Category.Item: Hashable {
}

extension Category.Item: Identifiable {
}

extension Category.Item: Sendable {
}
