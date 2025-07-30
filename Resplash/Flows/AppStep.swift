//
//  AppStep.swift
//  Resplash
//
//  Created by 정재성 on 7/27/25.
//

import Foundation
import RxFlow

enum AppStep: Step {
  case root

  case mainTab
  case exploreTab
  case myTab
  case searchTab

  case collections(MediaType)
  case topicImages(Topic)
  case collectionImages(ImageAssetCollection)
  case categoryImages(Category.Item)
  case imageDetail(ImageAsset)
  case search(String)
  case share(URL)
}
