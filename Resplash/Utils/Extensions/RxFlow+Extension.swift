//
//  RxFlow+Extension.swift
//  Resplash
//
//  Created by 정재성 on 7/27/25.
//

import RxFlow
import ReactorKit

extension FlowContributor {
  static func contribute<Presentable: BaseViewController<Reactor>, Reactor: BaseReactor>(with presentable: Presentable) -> FlowContributor {
    return .contribute(withNextPresentable: presentable, withNextStepper: presentable)
  }

  static func contribute(with presentable: Presentable, step: Step) -> FlowContributor {
    return .contribute(
      withNextPresentable: presentable,
      withNextStepper: OneStepper(withSingleStep: step),
      allowStepWhenNotPresented: false,
      allowStepWhenDismissed: false
    )
  }
}
