import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  type: Core.self,
  packages: [
    .package(url: "https://github.com/liamnichols/xcstrings-tool-plugin", from: "1.2.0")
  ],
  dependencies: {
    switch $0 {
    case .utils:
      return [
        .external(.algorithms)
      ]
    case .log:
      return [
        .external(.logging)
      ]
    case .designSystem:
      return [
        .core(.utils)
      ]
    case .networking:
      return [
        .core(.utils),
        .core(.log),
        .external(.alamofire)
      ]
    case .strings:
      return [
        .plugin(.xcstringsToolPlugin)
      ]
    }
  }
)
