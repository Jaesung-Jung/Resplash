//
//  SearchViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/9/25.
//

import UIKit

final class SearchViewController: BaseViewController<NoReactor> {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = .localized("Search")
  }
}

// MARK: - SearchViewController

#Preview {
  UINavigationController(rootViewController: SearchViewController())
}
