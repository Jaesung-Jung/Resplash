//
//  Trend.swift
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
public struct Trend {
  public let id = UUID()
  public let title: String
  public let demand: Demand
  public let thumbnailURL: ImageURL
  public let growth: Int
  public let results: Int
  public let searchViews: Int
  public let keywords: [Keyword]
}

extension Trend: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

extension Trend: Identifiable {
}

extension Trend: Sendable {
}

// MARK: - Trend.Demand

extension Trend {
  public enum Demand: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
  }
}

extension Trend.Demand: Sendable {
}

// MARK: - Trend.Keyword

extension Trend {
  @MemberwiseInit(.public)
  public struct Keyword {
    public let id = UUID()
    public let title: String
    public let demand: Demand
    public let thumbnailURL: ImageURL
    public let growth: Int
    public let results: Int
    public let searchViews: Int
  }
}

extension Trend.Keyword: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

extension Trend.Keyword: Identifiable {
}

extension Trend.Keyword: Sendable {
}
