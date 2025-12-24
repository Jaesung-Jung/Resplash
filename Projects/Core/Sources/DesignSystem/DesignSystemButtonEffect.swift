//
//  DesignSystemButtonEffect.swift
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

// MARK: - DesignSystemButtonEffect

@MainActor public protocol DesignSystemButtonEffect {
  associatedtype Modifier: ViewModifier

  func modifier(isPressed: Bool) -> Modifier
}

extension DesignSystemButtonEffect where Self == DesignSystemButtonEffects {
  public static var `default`: some DesignSystemButtonEffect {
    DesignSystemScaleButtonEffect()
  }

  public static func scale(_ scale: CGFloat) -> some DesignSystemButtonEffect {
    DesignSystemScaleButtonEffect(scale: scale)
  }

  public static func background(padding: EdgeInsets? = nil) -> some DesignSystemButtonEffect {
    DesignSystemBackgroundButtonEffect(shape: .tertiary, padding: padding)
  }

  public static func background<Shape: ShapeStyle>(_ shape: Shape, padding: EdgeInsets? = nil) -> some DesignSystemButtonEffect {
    DesignSystemBackgroundButtonEffect(shape: shape, padding: padding)
  }
}

// MARK: - DesignSystemButtonEffects

public enum DesignSystemButtonEffects: DesignSystemButtonEffect {
  public struct Modifier: ViewModifier {
    public init(isPressed: Bool) {}
    public func body(content: Content) -> some View {}
  }

  public func modifier(isPressed: Bool) -> Modifier {
    Modifier(isPressed: isPressed)
  }
}

// MARK: - DesignSystemScaleButtonEffect

struct DesignSystemScaleButtonEffect: DesignSystemButtonEffect {
  let scale: CGFloat

  init(scale: CGFloat = 0.95) {
    self.scale = scale
  }

  struct Modifier: ViewModifier {
    let scale: CGFloat
    let isPressed: Bool

    func body(content: Content) -> some View {
      content
        .scaleEffect(isPressed ? scale : 1)
        .animation(.spring(duration: 0.35, bounce: 0.5), value: isPressed)
    }
  }

  func modifier(isPressed: Bool) -> Modifier {
    Modifier(scale: scale, isPressed: isPressed)
  }
}

// MARK: - DesignSystemBackgroundButtonEffect

struct DesignSystemBackgroundButtonEffect<Shape: ShapeStyle>: DesignSystemButtonEffect {
  let shape: Shape
  let padding: EdgeInsets?

  struct Modifier: ViewModifier {
    let isPressed: Bool
    let shape: Shape
    let padding: EdgeInsets

    func body(content: Content) -> some View {
      content
        .background {
          RoundedRectangle(cornerRadius: 8)
            .fill(shape)
            .opacity(isPressed ? 1 : 0)
            .padding(padding)
        }
        .animation(.smooth, value: isPressed)
    }
  }

  func modifier(isPressed: Bool) -> Modifier {
    Modifier(isPressed: isPressed, shape: shape, padding: padding ?? EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
  }
}
