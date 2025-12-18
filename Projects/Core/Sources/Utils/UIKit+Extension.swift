//
//  UIKit+Extension.swift
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

import UIKit

extension UIImage {
  /// Resizes the image to fit within the given bounds, maintaining the original aspect ratio.
  ///
  /// - Parameter boundsSize: The size within which the image should fit.
  /// - Returns: A new resized `UIImage`, or `nil` if the resizing fails.
  public func resize(in boundsSize: CGSize) -> UIImage? {
    let ratio = min(boundsSize.width / size.width, boundsSize.height / size.height)
    return resize(to: CGSize(width: size.width * ratio, height: size.height * ratio))
  }

  /// Resizes the image to the specified size.
  ///
  /// - Parameter size: The new size of the image.
  /// - Returns: A new resized `UIImage`, or `nil` if the resizing fails.
  public func resize(to size: CGSize) -> UIImage? {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
      draw(in: CGRect(origin: .zero, size: size))
    }
  }
}
