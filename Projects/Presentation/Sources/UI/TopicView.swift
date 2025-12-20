//
//  TopicView.swift
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
import ResplashEntities
import ResplashDesignSystem

public struct TopicView: View {
  @Environment(\.displayScale) var displayScale
  @Environment(\.dynamicTypeSize) var dynamicTypeSize
  let topic: Topic

  public init(_ topic: Topic) {
    self.topic = topic
  }

  public var body: some View {
    IconLabel(spacing: 0) {
      Circle()
        .strokeBorder(.quaternary, lineWidth: 1 / displayScale)
        .aspectRatio(1, contentMode: .fit)
        .background {
          RemoteImage(topic.coverImage.url.low) {
            $0.resizable()
              .aspectRatio(contentMode: .fill)
          }
          .clipShape(Circle())
        }
    } content: {
      Text(topic.title)
        .font(.subheadline)
        .fontWeight(.semibold)
        .padding(8)
    }
    .padding(dynamicTypeSize.isAccessibilitySize ? 6 : 4)
  }
}

// MARK: - TopicView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  TopicView(.preview)
}

#endif
