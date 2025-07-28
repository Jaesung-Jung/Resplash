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

// MARK: - UIImageView (Reactive)

extension Reactive where Base: UIImageView {
  var imageURL: Binder<URL?> {
    Binder(base) { imageView, url in
      MainActor.assumeIsolated {
        imageView.setImageURL(url)
      }
    }
  }
}

// MARK: - UIViewController (Reactive)

extension Reactive where Base: UIViewController {
  var viewDidLoad: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
    return ControlEvent(events: source)
  }

  var viewWillAppear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewWillAppear(_:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewIsAppearing: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewIsAppearing(_:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewDidAppear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewDidAppear(_:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewWillDisappear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewWillDisappear(_:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewDidDisappear: ControlEvent<Bool> {
    let source = methodInvoked(#selector(Base.viewDidDisappear(_:))).map { $0.first as? Bool ?? false }
    return ControlEvent(events: source)
  }

  var viewWillLayoutSubviews: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { _ in }
    return ControlEvent(events: source)
  }

  var viewDidLayoutSubviews: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in }
    return ControlEvent(events: source)
  }

  var didReceiveMemoryWarning: ControlEvent<Void> {
    let source = methodInvoked(#selector(Base.didReceiveMemoryWarning)).map { _ in }
    return ControlEvent(events: source)
  }
}
