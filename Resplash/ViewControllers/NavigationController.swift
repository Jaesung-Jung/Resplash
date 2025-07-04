//
//  NavigationController.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import UIKit

final class NavigationController: UINavigationController {
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationBar.prefersLargeTitles = true
  }
}
