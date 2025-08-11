//
//  BaseReactor.swift
//  Resplash
//
//  Created by 정재성 on 7/8/25.
//

import Foundation
import RxSwift
import ReactorKit

protocol BaseReactor: AnyObject, Reactor {
}

extension BaseReactor {
  func transform(state: Observable<State>) -> Observable<State> {
    return state.observe(on: MainScheduler.instance)
  }
}

final class NoReactor: BaseReactor {
  typealias Action = NoAction
  typealias Mutation = NoMutation

  struct State {
  }

  let initialState = State()
}
