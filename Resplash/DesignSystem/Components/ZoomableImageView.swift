//
//  ZoomableImageView.swift
//  Resplash
//
//  Created by 정재성 on 7/27/25.
//

import UIKit

// MARK: - ZoomableImageView

class ZoomableImageView: UIView {
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }

  let scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.bouncesZoom = true
    $0.bounces = true
    $0.minimumZoomScale = 1.0
    $0.maximumZoomScale = 4.0
    $0.backgroundColor = .clear
    $0.contentInsetAdjustmentBehavior = .never
  }

  @inlinable var minimumZoomScale: CGFloat {
    get { scrollView.minimumZoomScale }
    set { scrollView.minimumZoomScale = newValue }
  }

  @inlinable var maximumZoomScale: CGFloat {
    get { scrollView.maximumZoomScale }
    set { scrollView.maximumZoomScale = newValue }
  }

  var image: UIImage? {
    get { imageView.image }
    set {
      imageView.image = newValue
      imageDidUpdate()
    }
  }

  var zoomsOnDoubleTap: Bool = true {
    didSet {
      tapGestureRecognizer.isEnabled = zoomsOnDoubleTap
    }
  }

  var isZoomed: Bool { scrollView.zoomScale > 1.0 }

  private(set) var isZoomAnimating: Bool = false

  var contentViewFrame: CGRect {
    CGRect(
      x: -scrollView.contentOffset.x,
      y: -scrollView.contentOffset.y,
      width: imageView.frame.width,
      height: imageView.frame.height
    )
  }

  let tapGestureRecognizer = UITapGestureRecognizer().then {
    $0.numberOfTapsRequired = 2
  }

  var imageContentMode: ImageContentMode = .fit {
    didSet {
      if imageContentMode != oldValue {
        setNeedsLayout()
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  convenience init(image: UIImage) {
    self.init(frame: .zero)
    self.image = image
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    scrollView.frame = bounds
    if !isZoomed {
      switch imageContentMode {
      case .fit:
        let fitSize = sizeThatFits(in: bounds)
        imageView.frame = CGRect(origin: CGPoint.zero, size: fitSize)

        let inset = contentInsetForCenter(in: bounds)
        scrollView.contentInset = inset
      case .fill:
        let fitSize = sizeThatFills(in: bounds)
        imageView.frame = CGRect(origin: CGPoint.zero, size: fitSize)

        let offset = contentOffsetForCenter(in: bounds)
        scrollView.contentOffset = offset
      }
      scrollView.contentSize = imageView.frame.size
    }
  }

  func zoom(to scale: CGFloat, animated: Bool, completion: (() -> Void)? = nil) {
    if animated {
      isZoomAnimating = true
      let animator = makeZoomAnimator()
      animator.addAnimations {
        self.scrollView.setZoomScale(scale, animated: false)
      }
      animator.addCompletion { _ in
        self.isZoomAnimating = false
        completion?()
      }
      animator.startAnimation()
    }
    scrollView.setZoomScale(scale, animated: false)
  }

  func setImage(_ url: URL?) {
    imageView.setImageURL(url) { [weak self] in
      self?.imageDidUpdate()
    }
  }
}

// MARK: - ZoomableImageView (UIScrollViewDelegate)

extension ZoomableImageView: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    let inset = contentInsetForCenter(in: scrollView.bounds)
    scrollView.contentInset = inset
  }
}

// MARK: - ZoomableImageView (Actions)

extension ZoomableImageView {
  @objc func handleDoubleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
    if scrollView.zoomScale != 1 {
      zoom(to: 1, animated: true)
    } else {
      let touchLocation = gestureRecognizer.location(in: gestureRecognizer.view)
      let newZoomScale: CGFloat = 2.0
      let width = bounds.width / newZoomScale
      let height = bounds.height / newZoomScale

      isZoomAnimating = true
      let animator = makeZoomAnimator()
      animator.addAnimations {
        self.scrollView.zoom(
          to: CGRect(
            x: touchLocation.x - width / 2.0,
            y: touchLocation.y - height / 2.0,
            width: width,
            height: height
          ),
          animated: false
        )
      }
      animator.addCompletion { _ in
        self.isZoomAnimating = false
      }
      animator.startAnimation()
    }
  }
}

// MARK: - ZoomableImageView (Private)

extension ZoomableImageView {
  private func setup() {
    clipsToBounds = true
    scrollView.delegate = self
    scrollView.addSubview(imageView)
    scrollView.addGestureRecognizer(tapGestureRecognizer)
    addSubview(scrollView)

    tapGestureRecognizer.addTarget(self, action: #selector(ZoomableImageView.handleDoubleTapGesture(_:)))
  }

  private func sizeThatFits(in bounds: CGRect) -> CGSize {
    guard let image = imageView.image else {
      return .zero
    }
    let wRatio = bounds.width / image.size.width
    let hRatio = bounds.height / image.size.height
    let ratio = min(wRatio, hRatio)
    return CGSize(
      width: (image.size.width * ratio).rounded(.up),
      height: (image.size.height * ratio).rounded(.up)
    )
  }

  private func sizeThatFills(in bounds: CGRect) -> CGSize {
    guard let image = imageView.image else {
      return .zero
    }
    let ratio = bounds.height / image.size.height
    return CGSize(
      width: (image.size.width * ratio).rounded(.up),
      height: (image.size.height * ratio).rounded(.up)
    )
  }

  private func contentInsetForCenter(in bounds: CGRect) -> UIEdgeInsets {
    let top = (bounds.height - imageView.frame.height) * 0.5
    let left = (bounds.width - imageView.frame.width) * 0.5
    return UIEdgeInsets(top: max(0.0, top), left: max(0.0, left), bottom: 0, right: 0)
  }

  private func contentOffsetForCenter(in bounds: CGRect) -> CGPoint {
    return CGPoint(x: (imageView.frame.width - bounds.width) * 0.5, y: 0)
  }

  private func imageDidUpdate() {
    scrollView.setZoomScale(1.0, animated: false)
    layoutSubviews()
  }

  private func makeZoomAnimator() -> UIViewPropertyAnimator {
    return UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
  }
}

// MARK: - ZoomableImageView.ImageContentMode

extension ZoomableImageView {
  enum ImageContentMode {
    case fit
    case fill
  }
}
