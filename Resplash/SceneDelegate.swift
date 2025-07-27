//
//  SceneDelegate.swift
//  Resplash
//
//  Created by 정재성 on 7/3/25.
//

import UIKit
import RxFlow
import RxSwift
import Dependencies

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  let coordinator = FlowCoordinator()
  let disposeBag = DisposeBag()

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }
    let appFlow = AppFlow(windowScene: windowScene)
    window = appFlow.window

    coordinator.coordinate(flow: appFlow, with: OneStepper(withSingleStep: AppStep.root))
    #if DEBUG
      coordinator.rx.willNavigate
        .subscribe(onNext: {
          print("👉 will navigate to flow=\($0) and step=\($1)")
        })
        .disposed(by: disposeBag)
    #endif
  }
}
