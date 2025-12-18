//
//  Topic.swift
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
public struct Topic {
  public let id: String
  public let slug: String
  public let visibility: Visibility
  public let owners: [User]

  public let title: String
  public let description: String
  public let mediaTypes: Set<MediaType>
  public let coverImage: Asset

  public let imageCount: Int
  public let shareLink: URL
}

extension Topic: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Topic: Identifiable {
}

extension Topic: Sendable {
}

// MARK: - Topic.Visibility

extension Topic {
  public enum Visibility: String {
    case featured
    case visible
  }
}

extension Topic.Visibility: Sendable {
}
