//
//  SceneDelegate.swift
//  Resplash
//
//  Created by 정재성 on 7/3/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }
    window = UIWindow(windowScene: windowScene).then {
      $0.rootViewController = UIViewController()
      $0.makeKeyAndVisible()
    }
  }
}
