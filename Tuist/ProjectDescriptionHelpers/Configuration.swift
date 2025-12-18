import Foundation
import ProjectDescription

public enum ProjectConfig {
  public static let name = "Resplash"
  static func bundleIdentifier(_ suffixes: String...) -> String {
    [["com.js.resplash"], suffixes.map { $0.lowercased() }]
      .flatMap { $0 }
      .joined(separator: ".")
  }

  static let developmentRegion = "en"
  static let knownRegions = [
    "Base",
    "en",   // English
    "ko",   // Korean
    "ja"    // Japanese
  ]

  static let deploymentTargets: DeploymentTargets = .iOS("18.0")

  static let marketingVersion = "1.0.0"
  static let projectVersion = "1"

  static let destinations: Destinations = [.iPhone, .iPad]
}

// MARK: - Project.Options

extension Project.Options {
  public static func projectDefault(_ configure: ((inout Project.Options) -> Void)? = nil) -> Project.Options {
    var options = Project.Options.options(
      automaticSchemesOptions: .enabled(targetSchemesGrouping: .notGrouped),
      defaultKnownRegions: ProjectConfig.knownRegions,
      developmentRegion: ProjectConfig.developmentRegion,
      disableBundleAccessors: true,
      disableSynthesizedResourceAccessors: true,
      textSettings: .textSettings(
        usesTabs: false,
        indentWidth: 2,
        tabWidth: 2
      )
    )
    configure?(&options)
    return options
  }
}

// MARK: - Project Settings
extension Settings {
  public static func projectDefault(_ configure: ((inout Settings) -> Void)? = nil) -> Settings {
    var settings = Settings.settings(
      base: [
        "SWIFT_VERSION": "6.0",
        "STRING_CATALOG_GENERATE_SYMBOLS": "YES"
      ],
      defaultSettings: .recommended
    )
    configure?(&settings)
    return settings
  }
}

// MARK: - BuildableFolder

extension BuildableFolder {
  public static let sources: BuildableFolder = "Sources"
  public static let resources: BuildableFolder = "Resources"
  public static let tests: BuildableFolder = "Tests"

  public static func sources<M: Module>(_ module: M) -> BuildableFolder {
    BuildableFolder(stringLiteral: "Sources/\(module.target.description)")
  }

  public static func tests<M: Module>(_ module: M) -> BuildableFolder {
    BuildableFolder(stringLiteral: "Tests/\(module.target.description)Tests")
  }
}

// MARK: - Destinations

extension Destinations {
  public static var defaultDestinations: Destinations {
    ProjectConfig.destinations
  }
}
