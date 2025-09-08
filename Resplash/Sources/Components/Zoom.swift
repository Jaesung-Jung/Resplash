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
  private let zoomScale: Binding<CGFloat>?
  private let minimumZoomScale: CGFloat
  private let maximumZoomScale: CGFloat
  private let content: Content

  init(zoomScale: Binding<CGFloat>? = nil, minimumZoomScale: CGFloat = 1, maximumZoomScale: CGFloat = 3, @ViewBuilder content: () -> Content) {
    self.zoomScale = zoomScale
    self.minimumZoomScale = minimumZoomScale
    self.maximumZoomScale = maximumZoomScale
    self.content = content()
  }

  func makeUIView(context: Context) -> UIView {
    ScrollWrapperView(scale: zoomScale ?? .constant(1), content: content)
  }

  func updateUIView(_ view: UIView, context: Context) {
    guard let view = view as? ScrollWrapperView else {
      return
    }
    view.context = context
    view.scrollView.minimumZoomScale = minimumZoomScale
    view.scrollView.maximumZoomScale = maximumZoomScale
    if let zoomScale = zoomScale?.wrappedValue, view.scrollView.zoomScale != zoomScale {
      context.animate {
        view.scrollView.setZoomScale(zoomScale, animated: false)
      }
    }
  }
}

// MARK: - Zoom.ScrollWrapperView

extension Zoom {
  private class ScrollWrapperView: UIView, UIScrollViewDelegate {
    private(set) var isInitialized = false
    private var shouldAdjustContentInset: Bool = true

    @Binding var zoomScale: CGFloat
    let hostingController: UIHostingController<Content>

    let scrollView = UIScrollView().then {
      $0.showsVerticalScrollIndicator = false
      $0.showsHorizontalScrollIndicator = false
      $0.bouncesZoom = true
      $0.bounces = true
      $0.backgroundColor = .clear
      $0.contentInsetAdjustmentBehavior = .never
      $0.clipsToBounds = false
    }

    var context: UIViewRepresentableContext<Zoom<Content>>?

    @inlinable var contentView: UIView { hostingController.view }
    @inlinable var isZoomed: Bool { scrollView.zoomScale > 1 }

    init(scale: Binding<CGFloat>, content: Content) {
      _zoomScale = scale
      hostingController = UIHostingController(rootView: content)
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
      let scale = scrollView.zoomScale
      let fitSize = contentView.sizeThatFits(bounds.size)
      let contentSize = CGSize(
        width: fitSize.width * scale,
        height: fitSize.height * scale
      )

      contentView.frame = CGRect(origin: .zero, size: contentSize)
      scrollView.frame = bounds
      scrollView.zoomScale = scale
      scrollView.contentInset = contentInset(for: contentSize, in: bounds)
      if shouldAdjustContentInset {
        shouldAdjustContentInset = false
        scrollView.contentOffset = CGPoint(
          x: (contentSize.width - bounds.width) * 0.5,
          y: (contentSize.height - bounds.height) * 0.5
        )
      }
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

    private func adjustContentInset(_ scale: CGFloat) {
      scrollView.contentInset = contentInset(
        for: contentView.frame.size,
        in: scrollView.bounds
      )
      if zoomScale != scale {
        DispatchQueue.main.async {
          self.zoomScale = scale
        }
      }
    }

    @objc
    private func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
      let hasAnimation = context?.transaction.animation != nil
      let animations: () -> Void
      if isZoomed {
        animations = { [scrollView] in
          scrollView.setZoomScale(max(scrollView.minimumZoomScale, 1), animated: !hasAnimation)
        }
      } else {
        let location = gestureRecognizer.location(in: gestureRecognizer.view)
        let scale = scrollView.maximumZoomScale
        let width = bounds.width / scale
        let height = bounds.height / scale
        let rect = CGRect(x: location.x - width * 0.5, y: location.y - height * 0.5, width: width, height: height)
        animations = { [scrollView] in
          scrollView.zoom(to: rect, animated: !hasAnimation)
        }
      }

      if let context {
        context.animate(changes: animations)
      } else {
        animations()
      }
    }

    // MARK: UISCrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { contentView }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
      adjustContentInset(scrollView.zoomScale)
    }
  }
}
