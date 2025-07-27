//
//  MainFlow.swift
//  Resplash
//
//  Created by 정재성 on 7/27/25.
//

import UIKit
import RxFlow

final class MainTabFlow: Flow {
  let navigationController = UINavigationController()

  var root: any Presentable { navigationController }

  func navigate(to step: any Step) -> FlowContributors {
    guard let step = step as? AppStep else {
      return .none
    }
    switch step {
    case .mainTab:
      let viewController = MainViewController(reactor: MainViewReactor())
      navigationController.pushViewController(viewController, animated: true)
      return .one(flowContributor: .contribute(with: viewController))
    default:
      return .one(flowContributor: .forwardToParentFlow(withStep: step))
    }
  }
}
