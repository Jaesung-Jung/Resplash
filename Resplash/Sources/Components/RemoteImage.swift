//
//  RemoteImage.swift
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
import Kingfisher

struct RemoteImage<Content: View>: View {
  let url: URL?
  let content: (Image) -> Content

  @Binding var isCompleted: Bool
  @State var phase: Phase = .idle

  init(_ url: URL?, isCompleted: Binding<Bool> = .constant(false), @ViewBuilder content: @escaping (Image) -> Content) {
    self.url = url
    self.content = content
    self._isCompleted = isCompleted
  }

  var body: some View {
    KFImage(url)
      .fade(duration: 0.25)
      .contentConfigure(content)
      .onSuccess { _ in phase = .success }
      .onFailure { _ in phase = .failure }
      .onChange(of: phase) { oldPhase, newPhase in
        if phase == .success, oldPhase != newPhase {
          isCompleted = true
        }
      }
      .onAppear { phase = .loading }
      .background {
        if phase == .idle || phase == .loading {
          Rectangle()
            .fill(.tertiary)
            .opacity(phase == .loading ? 0.25 : 1)
            .animation(.linear(duration: 1).repeatForever(autoreverses: true), value: phase == .loading)
        }
      }
  }
}

// MARK: - RemoteImage<Image>

extension RemoteImage where Content == Image {
  init(_ url: URL?) {
    self.init(url, content: { $0 })
  }
}

// MARK: - RemoteImage.Phase

extension RemoteImage {
  enum Phase {
    case idle
    case loading
    case success
    case failure
  }
}

// MARK: - RemoteImage Preview

#if DEBUG

#Preview {
  RemoteImage(ImageURL.preview.s3)
}

#endif
