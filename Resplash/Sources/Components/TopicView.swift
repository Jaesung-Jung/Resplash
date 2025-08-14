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

struct TopicView: View {
  let topic: Topic

  init(_ topic: Topic) {
    self.topic = topic
  }

  var body: some View {
    VStack {
      IconLabel(spacing: 0) {
        Circle()
          .fill(.clear)
          .aspectRatio(1, contentMode: .fit)
          .overlay {
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
      .padding(4)
      .background {
        Capsule()
          .stroke(.quinary, lineWidth: 0.5)
          .opacity(0.5)
      }
      .glassEffect(.identity.interactive())
    }
  }
}

// MARK: - TopicView Preview

#if DEBUG

#Preview {
  TopicView(.preview)
}

#endif
