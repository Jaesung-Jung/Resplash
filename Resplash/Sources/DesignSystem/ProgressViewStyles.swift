//
//  ProgressViewStyles.swift
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

// MARK: - CircleFadeProgressViewStyle

struct CircleFadeProgressViewStyle: ProgressViewStyle {
  @Environment(\.controlSize) var controlSize

  func makeBody(configuration: Configuration) -> some View {
    VStack {
      AnimatableCircle(controlSize: controlSize) { circle, flag in
        circle.opacity(flag ? 0.5 : 1)
      }
      configuration.label
    }
  }
}

// MARK: - CircleScaleProgressViewStyle

struct CircleScaleProgressViewStyle: ProgressViewStyle {
  @Environment(\.controlSize) var controlSize
  let anchor: UnitPoint

  func makeBody(configuration: Configuration) -> some View {
    VStack {
      AnimatableCircle(controlSize: controlSize) { circle, flag in
        circle
          .opacity(flag ? 0.5 : 1)
          .scaleEffect(flag ? 0.7 : 1, anchor: anchor)
      }
      configuration.label
    }
  }
}

// MARK: - ProgressEllipsis

private struct AnimatableCircle<Content: View>: View {
  @State var animating = false

  let radius: CGFloat
  let transform: (Circle, Bool) -> Content
  let animation = Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)

  init(controlSize: ControlSize, @ViewBuilder transform: @escaping (Circle, Bool) -> Content) {
    switch controlSize {
    case .mini:
      radius = 4
    case .small:
      radius = 6
    case .regular:
      radius = 8
    case .large:
      radius = 10
    case .extraLarge:
      radius = 12
    @unknown default:
      fatalError("Unknown controlSize")
    }
    self.transform = transform
  }

  var body: some View {
    HStack(spacing: radius) {
      ForEach(0..<3, id: \.self) { offset in
        transform(Circle(), animating)
          .frame(width: radius * 2, height: radius * 2)
          .animation(animation.delay(0.25 * Double(offset)), value: animating)
      }
    }
    .onAppear {
      withAnimation(animation) {
        animating = true
      }
    }
  }
}

// MARK: - ProgressViewStyle

extension ProgressViewStyle where Self == CircleFadeProgressViewStyle {
  static var circleFade: CircleFadeProgressViewStyle { CircleFadeProgressViewStyle() }
}

extension ProgressViewStyle where Self == CircleScaleProgressViewStyle {
  static var circleScale: CircleScaleProgressViewStyle { CircleScaleProgressViewStyle(anchor: .center) }
  static func circleScale(_ anchor: UnitPoint = .center) -> CircleScaleProgressViewStyle { CircleScaleProgressViewStyle(anchor: anchor) }
}

// MARK: - ProgressViewStyles Preview

#if DEBUG

#Preview {
  VStack(spacing: 80) {
    VStack(spacing: 20) {
      ForEach(ControlSize.allCases, id: \.self) {
        ProgressView()
          .progressViewStyle(.circleFade)
          .controlSize($0)
      }
    }

    VStack(spacing: 20) {
      ForEach(ControlSize.allCases, id: \.self) {
        ProgressView()
          .progressViewStyle(.circleScale)
          .controlSize($0)
      }
    }
  }
}

#endif
