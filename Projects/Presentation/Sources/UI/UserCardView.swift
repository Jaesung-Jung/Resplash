//
//  UserCardView.swift
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
import ResplashUtils

public struct UserCardView: View {
  let user: Unsplash.User

  public init(_ user: Unsplash.User) {
    self.user = user
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      IconLabel {
        Circle()
          .fill(.background)
          .stroke(.quaternary, lineWidth: 1)
          .overlay {
            RemoteImage(user.profileImageURL.large) {
              $0.resizable().aspectRatio(contentMode: .fill)
            }
            .clipShape(Circle())
          }
      } content: {
        VStack(alignment: .leading, spacing: 0) {
          Text(user.name)
            .fontWeight(.semibold)
          Text(user.userId)
            .textScale(.secondary)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
      }
      .lineLimit(1)

      Divider()

      Grid(alignment: .leading, horizontalSpacing: 2) {
        GridRow {
          ForEach(0..<3, id: \.self) { offset in
            Rectangle()
              .fill(.clear)
              .overlay {
                if let url = user.imageURLs[safe: offset] {
                  RemoteImage(url.sd) {
                    $0.resizable().aspectRatio(contentMode: .fill)
                  }
                }
              }
              .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
              .clipShape(RoundedRectangle(cornerRadius: 6))
          }
        }
      }
    }
    .padding(10)
    .background {
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(.quaternary, lineWidth: 1)
    }
    .contentShape(Rectangle())
  }
}

// MARK: - UserCardView Preview

#if DEBUG

import ResplashPreviewSupports

#Preview {
  UserCardView(.preview1)
    .frame(width: 300)
}

#endif
