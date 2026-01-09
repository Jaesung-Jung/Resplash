//
//  DesignSystemProgressViewStyle.swift
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

protocol DesignSystemProgressViewStyle {
}

extension DesignSystemProgressViewStyle {
  @inlinable func radius(for controlSize: ControlSize) -> CGFloat {
    switch controlSize {
    case .mini:
      return 4
    case .small:
      return 6
    case .regular:
      return 8
    case .large:
      return 10
    case .extraLarge:
      return 12
    @unknown default:
      fatalError("Unknown controlSize")
    }
  }
}

// MARK: - DesignSystemProgressViewStyles

public enum DesignSystemProgressViewStyles: ProgressViewStyle {
  public func makeBody(configuration: Configuration) -> some View {
  }

  public static var circleFade: DesignSystemCircleFadeProgressViewStyle {
    DesignSystemCircleFadeProgressViewStyle()
  }

  public static var circleScale: DesignSystemCircleScaleProgressViewStyle {
    DesignSystemCircleScaleProgressViewStyle(anchor: .center)
  }

  public static func circleScale(_ anchor: UnitPoint) -> DesignSystemCircleScaleProgressViewStyle {
    DesignSystemCircleScaleProgressViewStyle(anchor: anchor)
  }

  public static var circleBounce: DesignSystemCircleBounceProgressViewStyle {
    DesignSystemCircleBounceProgressViewStyle()
  }
}

extension ProgressViewStyle where Self == DesignSystemProgressViewStyles {
  public static var ds: DesignSystemProgressViewStyles.Type { DesignSystemProgressViewStyles.self }
}

// MARK: - DesignSystemCircleFadeProgressViewStyle

public struct DesignSystemCircleFadeProgressViewStyle: ProgressViewStyle, DesignSystemProgressViewStyle {
  @Environment(\.controlSize) var controlSize

  public func makeBody(configuration: Configuration) -> some View {
    let radius = radius(for: controlSize)
    VStack {
      HStack(spacing: radius) {
        ForEach(0..<3) { offset in
          ProgressCircle(radius: radius)
            .phaseAnimator([true, false]) { content, phase in
              content.opacity(phase ? 0.5 : 1)
            } animation: { _ in
              .linear.delay(0.25 * TimeInterval(offset))
            }
        }
      }

      configuration.label
    }
  }
}

// MARK: - DesignSystemCircleScaleProgressViewStyle

public struct DesignSystemCircleScaleProgressViewStyle: ProgressViewStyle, DesignSystemProgressViewStyle {
  @Environment(\.controlSize) var controlSize
  let anchor: UnitPoint

  public func makeBody(configuration: Configuration) -> some View {
    let radius = radius(for: controlSize)
    VStack {
      HStack(spacing: radius) {
        ForEach(0..<3) { offset in
          ProgressCircle(radius: radius)
            .phaseAnimator([true, false]) { content, phase in
              content
                .opacity(phase ? 0.5 : 1)
                .scaleEffect(phase ? 0.7 : 1, anchor: anchor)
            } animation: { _ in
              .bouncy.delay(0.25 * TimeInterval(offset))
            }
        }
      }

      configuration.label
    }
  }
}

// MARK: - DesignSystemCircleBounceProgressViewStyle

public struct DesignSystemCircleBounceProgressViewStyle: ProgressViewStyle {
  public func makeBody(configuration: Configuration) -> some View {
    HStack(spacing: 12) {
      ForEach(0..<3) { offset in
        ProgressCircle(radius: 6)
          .keyframeAnimator(initialValue: 0, repeating: true) { content, value in
            content
              .offset(y: value)
          } keyframes: { _ in
            CubicKeyframe(0, duration: TimeInterval(offset) * 0.1)
            CubicKeyframe(-10, duration: 0.3)
            CubicKeyframe(20, duration: 0.3)
            CubicKeyframe(-5, duration: 0.3)
            CubicKeyframe(0, duration: 0.3)
            LinearKeyframe(0, duration: 0.75 - TimeInterval(offset) * 0.1)
          }
      }
    }
  }
}

// MARK: - ProgressCircle

private struct ProgressCircle: View {
  let radius: CGFloat

  var body: some View {
    Circle()
      .frame(width: radius * 2)
  }
}

// MARK: - ProgressViewStyles Preview

#if DEBUG

#Preview {
  VStack(spacing: 80) {
    ProgressView()
      .progressViewStyle(.ds.circleFade)

    ProgressView()
      .progressViewStyle(.ds.circleScale)

    ProgressView()
      .progressViewStyle(.ds.circleBounce)
  }
  .foregroundStyle(.tertiary)
}

#endif
