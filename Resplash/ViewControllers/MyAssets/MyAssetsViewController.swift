//
//  MyAssetsViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import UIKit

final class MyAssetsViewController: BaseViewController<NoReactor> {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = .localized("My")
  }
}
