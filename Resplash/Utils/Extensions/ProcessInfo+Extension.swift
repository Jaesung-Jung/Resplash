//
//  ProcessInfo+e.swift
//  Resplash
//
//  Created by 정재성 on 7/4/25.
//

import Foundation

extension ProcessInfo {
  #if DEBUG
  public var isPreview: Bool {
    environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }
  #endif
}
