//
//  BaseViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import UIKit
import ReactorKit

class BaseViewController<R: Reactor>: UIViewController, ReactorKit.View {
  typealias State = R.State
  typealias Action = R.Action

  var disposeBag = DisposeBag()

  init(reactor: R? = nil) {
    super.init(nibName: nil, bundle: nil)
    self.reactor = reactor
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .app.background
  }

  func bind(reactor: R) {}
}
