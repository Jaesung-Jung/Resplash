import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
  type: Data.self,
  dependencies: {
    switch $0 {
    case .clientFactory:
      return [
        .domain(.clients),
        .domain(.entities),
        .core(.networking),
        .core(.utils)
      ]
    case .liveSupports:
      return [
        .data(.clientFactory)
      ]
    case .previewSupports:
      return [
        .data(.clientFactory)
      ]
    }
  }
)
