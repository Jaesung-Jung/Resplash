//
//  SearchViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/9/25.
//

import UIKit

final class SearchViewController: BaseViewController<NoReactor> {
  let searchController = UISearchController()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = .localized("Search")
    navigationItem.searchController = searchController
  }
}

// MARK: - SearchViewController

#Preview {
  UINavigationController(rootViewController: SearchViewController())
}
