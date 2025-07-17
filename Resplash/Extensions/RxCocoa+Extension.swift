//
//  RxCocoa+Extension.swift
//  Resplash
//
//  Created by 정재성 on 7/8/25.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - UIScrollView (Reactive)

extension Reactive where Base: UIScrollView {
  func reachedBottom(offset: CGFloat = 0.0) -> ControlEvent<Void> {
    let source = contentOffset
      .asObservable()
      .withUnretained(base)
      .filter { base, contentOffset in
        MainActor.assumeIsolated {
          let visibleHeight = base.frame.height - base.contentInset.top - base.contentInset.bottom
          let y = contentOffset.y + base.contentInset.top
          let threshold = max(offset, base.contentSize.height - visibleHeight)
          return y >= threshold
        }
      }
      .map { _ in }
    return ControlEvent(events: source)
  }
}

// MARK: - UITextField (Reactive)

extension Reactive where Base: UITextField {
  var keyboardReturn: ControlEvent<Void> {
    controlEvent(.editingDidEndOnExit)
  }
}

#if canImport(Kingfisher)

import Kingfisher

extension Reactive where Base: UIImageView {
  var imageURL: Binder<URL?> {
    Binder(base) { imageView, url in
      MainActor.assumeIsolated {
        imageView.kf.setImage(with: url)
      }
    }
  }
}

#endif
