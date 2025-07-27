//
//  BaseReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/8/25.
//

import Foundation
import RxFlow
import RxSwift
import RxRelay
import ReactorKit

protocol BaseReactor: AnyObject, Reactor, Stepper {
}

private var __stepsRelayAssociatedKey: UInt8 = 0

extension BaseReactor {
  func transform(state: Observable<State>) -> Observable<State> {
    return state.observe(on: MainScheduler.instance)
  }

  var steps: PublishRelay<Step> {
    if let object = objc_getAssociatedObject(self, &__stepsRelayAssociatedKey) as? PublishRelay<Step> {
      return object
    }
    let newObject = PublishRelay<Step>()
    objc_setAssociatedObject(self, &__stepsRelayAssociatedKey, newObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return newObject
  }
}

final class NoReactor: BaseReactor {
  typealias Action = NoAction
  typealias Mutation = NoMutation

  struct State {
  }

  let initialState = State()
}
