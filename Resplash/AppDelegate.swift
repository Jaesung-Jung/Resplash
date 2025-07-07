//
//  AppDelegate.swift
//  Resplash
//
//  Created by 정재성 on 7/3/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UINavigationBar.appearance().prefersLargeTitles = true
    UILabel.appearance().adjustsFontForContentSizeCategory = true
    return true
  }

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role).then {
      $0.delegateClass = SceneDelegate.self
    }
  }
}
