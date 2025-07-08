//
//  ExploreViewController.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import UIKit

final class ExploreViewController: BaseViewController<NoReactor> {
  let searchController = UISearchController()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Explore"
    navigationItem.searchController = searchController
  }
}
