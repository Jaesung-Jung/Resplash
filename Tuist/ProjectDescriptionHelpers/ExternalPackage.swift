import ProjectDescription

public struct ExternalPackage: Sendable {
  public let name: String
}

extension ExternalPackage {
  public static let algorithms = ExternalPackage(name: "Algorithms")
  public static let composableArchitecture = ExternalPackage(name: "ComposableArchitecture")
  public static let dependencies = ExternalPackage(name: "Dependencies")
  public static let alamofire = ExternalPackage(name: "Alamofire")
  public static let kingfisher = ExternalPackage(name: "Kingfisher")
  public static let logging = ExternalPackage(name: "Logging")
  public static let memberwiseInitMacro = ExternalPackage(name: "MemberwiseInit")
  public static let xcstringsToolPlugin = ExternalPackage(name: "XCStringsToolPlugin")
}

extension TargetDependency {
  public static func external(_ package: ExternalPackage, condition: PlatformCondition? = nil) -> TargetDependency {
    .external(name: package.name, condition: condition)
  }

  public static func plugin(_ package: ExternalPackage, condition: PlatformCondition? = nil) -> TargetDependency {
    .package(product: package.name, type: .plugin, condition: condition)
  }
}
