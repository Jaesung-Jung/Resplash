// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import enum ProjectDescription.Environment
import struct ProjectDescription.PackageSettings
import ProjectDescriptionHelpers

let packageSettings = if Environment.isDevelopment {
  PackageSettings(
    productTypes: [
      "ComposableArchitecture": .framework,
      "Dependencies": .framework,
      "CombineSchedulers": .framework,
      "ConcurrencyExtras": .framework,
      "IssueReporting": .framework,
      "IssueReportingPackageSupport": .framework,
      "XCTestDynamicOverlay": .framework
    ]
  )
} else {
  PackageSettings(productTypes: [:])
}
#endif

let package = Package(
  name: "Reader",
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.1"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.10.0"),
    .package(url: "https://github.com/Alamofire/Alamofire", from: "5.10.2"),
    .package(url: "https://github.com/onevcat/Kingfisher", from: "8.6.2"),
    .package(url: "https://github.com/apple/swift-log", from: "1.6.4"),
    .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.5.2")
  ]
)
