//
//  DesignSystemButtonStyle.swift
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

// MARK: - DesignSystemButtonStyle

protocol DesignSystemButtonStyle<Effect>: ButtonStyle {
  associatedtype Effect: DesignSystemButtonEffect

  var effect: Effect { get }
}

// MARK: - DesignSystemPlainButtonStyle

struct DesignSystemPlainButtonStyle<Effect: DesignSystemButtonEffect>: DesignSystemButtonStyle {
  @Environment(\.isEnabled) var isEnabled
  let effect: Effect

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(isEnabled ? 1 : 0)
      .overlay {
        if !isEnabled {
          configuration.label
            .foregroundStyle(.tertiary)
        }
      }
      .modifier(effect.modifier(isPressed: configuration.isPressed))
  }
}

// MARK: - DesignSystemButtonStyles

public enum DesignSystemButtonStyles: ButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
  }

  public static func plain() -> some ButtonStyle {
    DesignSystemPlainButtonStyle(effect: .default)
  }

  public static func plain<Effect: DesignSystemButtonEffect>(_ effect: Effect) -> some ButtonStyle {
    DesignSystemPlainButtonStyle(effect: effect)
  }
}

extension ButtonStyle where Self == DesignSystemButtonStyles {
  public static var ds: DesignSystemButtonStyles.Type { DesignSystemButtonStyles.self }
}

// MARK: - DesignSystemButtonStyle Preview

#if DEBUG

#Preview {
  VStack {
    Button("Plain Button") {
    }
    .buttonStyle(.ds.plain())
  }
}

#endif
