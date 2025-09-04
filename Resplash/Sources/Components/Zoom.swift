//
//  Zoom.swift
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

struct Zoom<Content: View>: UIViewRepresentable {
  private let view: ScrollWrapperView

  init(@ViewBuilder content: () -> Content) {
    view = ScrollWrapperView(content: content)
  }

  func makeUIView(context: Context) -> UIView { view }

  func updateUIView(_ view: UIView, context: Context) {
  }
}

// MARK: - Zoom.ScrollWrapperView

extension Zoom {
  private class ScrollWrapperView: UIView, UIScrollViewDelegate {
    let hostingController: UIHostingController<Content>

    let scrollView = UIScrollView().then {
      $0.showsVerticalScrollIndicator = false
      $0.showsHorizontalScrollIndicator = false
      $0.bouncesZoom = true
      $0.bounces = true
      $0.minimumZoomScale = 1.0
      $0.maximumZoomScale = 2.0
      $0.backgroundColor = .clear
      $0.contentInsetAdjustmentBehavior = .never
      $0.clipsToBounds = false
    }

    @inlinable var contentView: UIView { hostingController.view }
    @inlinable var isZoomed: Bool { scrollView.zoomScale > 1 }

    init(@ViewBuilder content: () -> Content) {
      hostingController = UIHostingController(rootView: content())
      super.init(frame: .zero)
      scrollView.delegate = self
      scrollView.addSubview(contentView)
      addSubview(scrollView)

      contentView.addGestureRecognizer(
        UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:))).then {
          $0.numberOfTapsRequired = 2
        }
      )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      scrollView.frame = bounds
      guard !isZoomed else {
        return
      }
      let contentSize = contentView.sizeThatFits(bounds.size)
      contentView.frame = CGRect(origin: .zero, size: contentSize)
      scrollView.contentInset = contentInset(for: contentSize, in: bounds)
    }

    private func contentInset(for size: CGSize, in bounds: CGRect) -> UIEdgeInsets {
      let top = (bounds.height - size.height) * 0.5
      let left = (bounds.width - size.width) * 0.5
      return UIEdgeInsets(
        top: max(.zero, top),
        left: max(.zero, left),
        bottom: .zero,
        right: .zero
      )
    }

    @objc
    private func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
      let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
      if scrollView.zoomScale != 1 {
        animator.addAnimations { [scrollView] in
          scrollView.setZoomScale(1, animated: false)
        }
      } else {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        let scale = 2.0
        let width = bounds.width / scale
        let height = bounds.height / scale
        let rect = CGRect(x: location.x - width * 0.5, y: location.y - height * 0.5, width: width, height: height)
        animator.addAnimations { [scrollView] in
          scrollView.zoom(to: rect, animated: false)
        }
      }
      animator.startAnimation()
    }

    // MARK: UISCrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { contentView }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
      let scale = scrollView.zoomScale
      let contentSize = contentView.sizeThatFits(bounds.size)
      scrollView.contentInset = contentInset(
        for: CGSize(width: contentSize.width * scale, height: contentSize.height * scale),
        in: scrollView.bounds
      )
    }
  }
}
