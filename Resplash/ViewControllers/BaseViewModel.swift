//
//  BaseViewModel.swift
//  Resplash
//
//  Created by 정재성 on 7/5/25.
//

import Foundation

protocol ViewModel {
  associatedtype State
  associatedtype Action

  var state: State { get }

  func perform(_ action: Action)

  func setState(_ newState: State)
  func setError(_ error: Error)
}

extension ViewModel {
  func updateState(_ mutation: (inout State) -> Void) {
    var newState = state
    mutation(&newState)
    setState(newState)
  }

  func updateState<T>(with result: Result<T, Error>, mutation: (inout State, T) -> Void) {
    switch result {
    case .success(let success):
      var newState = state
      mutation(&newState, success)
      setState(newState)
    case .failure(let failure):
      setError(failure)
    }
  }
}
