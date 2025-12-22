import ProjectDescription

// MARK: - Module

public protocol Module: Sendable {
  associatedtype Target: ModuleTarget

  /// 모듈 명
  static var name: String { get }
  /// 모듈 경로
  static var path: Path { get }

  /// 타겟
  var target: Target { get }

  init(target: Target)
}

extension Module {
  public static var path: Path {
    return .relativeToRoot("Projects/\(name)")
  }
}

// MARK: - ModuleTarget

public protocol ModuleTarget: CustomStringConvertible, CaseIterable, Sendable {
  associatedtype RawValue = String
}

extension ModuleTarget where Self: RawRepresentable, RawValue == String {
  public var description: String {
    String(rawValue.prefix(1).uppercased() + rawValue.dropFirst())
  }
}

// MARK: - Presentation

public struct Presentation: Module {
  public static let name = "Presentation"

  public let target: Target

  public init(target: Target) {
    self.target = target
  }

  public enum Target: String, ModuleTarget {
    case ui = "UI"
    case appUI
    case homeUI
    case exploreUI
    case searchUI
    case collectionsUI
    case imagesUI
    case imageDetailUI
    case imageMapUI
    case imageViewerUI
  }
}

// MARK: - Domain

public struct Domain: Module {
  public static let name = "Domain"

  public let target: Target

  public init(target: Target) {
    self.target = target
  }

  public enum Target: String, ModuleTarget {
    case entities
    case clients
  }
}

// MARK: - Data

public struct Data: Module {
  public static let name = "Data"

  public let target: Target

  public init(target: Target) {
    self.target = target
  }

  public enum Target: String, ModuleTarget {
    case clientFactory
    case liveSupports
    case previewSupports
  }
}

// MARK: - Core

public struct Core: Module {
  public static let name = "Core"

  public let target: Target

  public init(target: Target) {
    self.target = target
  }

  public enum Target: String, ModuleTarget {
    case utils
    case log
    case designSystem
    case networking
    case strings
  }
}

// MARK: - TargetDependency

extension TargetDependency {
  public static func module<M: Module>(_ module: M) -> TargetDependency {
    .project(target: "\(module.target.description)", path: M.path)
  }

  public static func presentation(_ target: Presentation.Target) -> TargetDependency {
    .project(target: "\(target.description)", path: Presentation.path)
  }

  public static func domain(_ target: Domain.Target) -> TargetDependency {
    .project(target: "\(target.description)", path: Domain.path)
  }

  public static func data(_ target: Data.Target) -> TargetDependency {
    .project(target: "\(target.description)", path: Data.path)
  }

  public static func core(_ target: Core.Target) -> TargetDependency {
    .project(target: "\(target.description)", path: Core.path)
  }
}
