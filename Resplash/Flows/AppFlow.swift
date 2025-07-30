//
//  AppFlow.swift
//  Resplash
//
//  Created by 정재성 on 7/27/25.
//

import UIKit
import RxFlow
import RxSwift
import Dependencies

final class AppFlow: Flow {
  @Dependency(\.unsplashService) var unsplash

  let window: UIWindow
  let tabBarController = UITabBarController().then {
    if #available(iOS 26.0, *) {
      $0.tabBarMinimizeBehavior = .onScrollDown
    }
  }

  var root: any Presentable { tabBarController }

  init(windowScene: UIWindowScene) {
    self.window = UIWindow(windowScene: windowScene)
    self.window.rootViewController = tabBarController
    self.window.makeKeyAndVisible()
  }

  func navigate(to step: any Step) -> FlowContributors {
    guard let step = step as? AppStep else {
      return .none
    }
    switch step {
    case .root:
      let mainTabFlow = MainTabFlow()
      let exploreTabFlow = ExploreTabFlow()
      let myTabFlow = MyTabFlow()
      let searchTabFlow = SearchTabFlow()
      Flows.use(mainTabFlow, exploreTabFlow, myTabFlow, searchTabFlow, when: .created) { main, explore, my, search in
        self.tabBarController.setTabs(
          [
            UITab(title: .localized("Image"), image: UIImage(systemName: "photo.on.rectangle.angled"), identifier: "images") { _ in main },
            UITab(title: .localized("Explore"), image: UIImage(systemName: "safari"), identifier: "explore") { _ in explore },
            UITab(title: .localized("My"), image: UIImage(systemName: "rectangle.stack.badge.person.crop"), identifier: "my") { _ in my },
            UISearchTab { _ in search }
          ],
          animated: true
        )
      }
      return .multiple(flowContributors: [
        .contribute(with: mainTabFlow, step: AppStep.mainTab),
        .contribute(with: exploreTabFlow, step: AppStep.exploreTab),
        .contribute(with: myTabFlow, step: AppStep.myTab),
        .contribute(with: searchTabFlow, step: AppStep.searchTab)
      ])

    case .collections(let mediaType):
      let imageCollectionsViewController = ImageCollectionsViewController(
        reactor: ImageCollectionsViewReactor(mediaType: mediaType)
      )
      navigate(to: imageCollectionsViewController, animated: true)
      return .one(flowContributor: .contribute(with: imageCollectionsViewController))

    case .topicImages(let topic):
      let imagesViewController = ImagesViewController(
        reactor: ImagesViewReactor(title: topic.title) { [unsplash] page in
          unsplash.images(for: topic, page: page)
        }
      )
      navigate(to: imagesViewController, animated: true)
      return .one(flowContributor: .contribute(with: imagesViewController))

    case .collectionImages(let collection):
      let imagesViewController = ImagesViewController(
        reactor: ImagesViewReactor(title: collection.title) { [unsplash] page in
          unsplash.images(for: collection, page: page)
        }
      )
      navigate(to: imagesViewController, animated: true)
      return .one(flowContributor: .contribute(with: imagesViewController))

    case .categoryImages(let categoryItem):
      if let redirect = categoryItem.redirect {
        return .one(flowContributor: .forwardToCurrentFlow(withStep: AppStep.search(redirect)))
      }
      let imagesViewController = ImagesViewController(
        reactor: ImagesViewReactor(title: categoryItem.title) { [unsplash] page in
          unsplash.images(for: categoryItem, page: page)
        }
      )
      navigate(to: imagesViewController, animated: true)
      return .one(flowContributor: .contribute(with: imagesViewController))

    case .imageDetail(let image):
      let detailViewController = ImageDetailViewController(reactor: ImageDetailViewReactor(image: image))
      navigate(to: detailViewController, animated: true)
      return .one(flowContributor: .contribute(with: detailViewController))

    case .search(let query):
      let searchResultViewController = SearchResultViewController(reactor: SearchResultViewReactor(query: query))
      navigate(to: searchResultViewController, animated: true)
      return .one(flowContributor: .contribute(with: searchResultViewController))

    case .share(let url):
      let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
      tabBarController.selectedViewController?.present(activityViewController, animated: true)
      return .none

    default:
      return .none
    }
  }

  private func navigate(to viewController: UIViewController, animated: Bool) {
    if let navigationController = tabBarController.selectedViewController as? UINavigationController {
      navigationController.pushViewController(viewController, animated: animated)
    } else {
      tabBarController.selectedViewController?.present(viewController, animated: animated)
    }
  }
}
