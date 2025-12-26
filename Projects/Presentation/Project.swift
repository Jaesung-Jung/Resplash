import ProjectDescription
import ProjectDescriptionHelpers

private func withPreviewSupports(_ dependencies: TargetDependency...) -> [TargetDependency] {
  Environment.isDevelopment ? dependencies + [.data(.previewSupports)] : dependencies
}

let project = Project.module(
  type: Presentation.self,
  dependencies: {
    switch $0 {
    case .ui:
      return withPreviewSupports(
        .domain(.entities),
        .core(.designSystem),
        .core(.strings)
      )
    case .appUI:
      return withPreviewSupports(
        .presentation(.homeUI),
        .presentation(.exploreUI),
        .presentation(.searchUI),
        .presentation(.collectionListUI),
        .presentation(.imageListUI),
        .presentation(.imageDetailUI),
        .presentation(.imageMapUI),
        .presentation(.searchResultUI),
        .presentation(.userListUI),
        .presentation(.userProfileUI),
        .core(.strings),
        .external(.composableArchitecture)
      )
    case .homeUI, .exploreUI, .searchUI, .collectionListUI, .imageListUI, .imageDetailUI, .imageMapUI, .searchResultUI, .userListUI, .userProfileUI:
      return withPreviewSupports(
        .presentation(.ui),
        .domain(.clients),
        .domain(.entities),
        .core(.strings),
        .external(.composableArchitecture)
      )
    }
  }
)
