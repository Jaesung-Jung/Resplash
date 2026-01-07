//
//  CircleImage.swift
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

public struct CircleImage<Content: View>: View {
  let content: Content

  public var body: some View {
    Circle()
      .fill(.clear)
      .background {
        content.aspectRatio(contentMode: .fill)
      }
      .clipShape(.circle)
      .contentShape(.circle)
  }

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
}

// MARK: - CircleImage<Image>

extension CircleImage where Content == Image {
  public init(_ resource: ImageResource) {
    self.init {
      Image(resource).resizable()
    }
  }

  public init(systemName: String) {
    self.init { Image(systemName: systemName).resizable() }
  }

  public init(uiImage: UIImage) {
    self.init { Image(uiImage: uiImage).resizable() }
  }
}

// MARK: - CircleImage<RemoteImage<Image>>

extension CircleImage where Content == RemoteImage<Image> {
  public init(_ url: URL) {
    self.init {
      RemoteImage(url) {
        $0.resizable()
      }
    }
  }
}

// MARK: - CircleImage Preview

#Preview {
  CircleImage(URL(string: "https://www.apple.com/newsroom/images/product/iphone/lifestyle/2022/Apple_Shot-on-iphone-macro-challenge_Cat_big.jpg")!)
    .frame(width: 300, height: 300)
}
