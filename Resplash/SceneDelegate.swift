//
//  SceneDelegate.swift
//  Resplash
//
//  Created by 정재성 on 7/3/25.
//

import UIKit
import Dependencies

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }
    // Dependencies
//    prepareDependencies {
//      $0.unsplashService = UnsplashService(strategy: .stub(delay: nil))
//    }

    // Root View
    let tabBarController = UITabBarController().then {
      $0.tabs = [
        UITab(title: "Image", image: UIImage(systemName: "photo.on.rectangle.angled"), identifier: "images") { _ in
          UINavigationController(rootViewController: ImagesViewController(reactor: ImagesViewReactor()))
        },
        UITab(title: "Collection", image: UIImage(systemName: "inset.filled.leadinghalf.toptrailing.bottomtrailing.rectangle"), identifier: "collection") { _ in
          UINavigationController(rootViewController: ImageCollectionsViewController())
        },
        UITab(title: "My", image: UIImage(systemName: "rectangle.stack.badge.person.crop"), identifier: "my") { _ in
          UINavigationController(rootViewController: MyAssetsViewController())
        },
        UISearchTab { _ in
          UINavigationController(rootViewController: ExploreViewController())
        }
      ]
    }
    window = UIWindow(windowScene: windowScene).then {
      $0.rootViewController = tabBarController
      $0.makeKeyAndVisible()
    }
  }
}
