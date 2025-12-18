import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  type: Domain.self,
  dependencies: {
    switch $0 {
    case .entities:
      return [
        .external(.memberwiseInitMacro)
      ]
    case .clients:
      return [
        .domain(.entities),
        .external(.dependencies)
      ]
    case .useCases:
      return [
        .domain(.entities),
        .domain(.clients),
        .external(.dependencies)
      ]
    }
  }
)
