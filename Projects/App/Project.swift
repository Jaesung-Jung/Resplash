import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
  productName: ProjectConfig.name,
  destinations: [.iPhone, .iPad],
  infoPlist: .extendingDefault(with: [
    "UILaunchScreen": [
      "UIImageName": "LaunchImage"
    ],
    "UIApplicationSceneManifest": [
      "UIApplicationSupportsMultipleScenes": false
    ],
    "UISupportedInterfaceOrientations": [
      "UIInterfaceOrientationPortrait"
    ]
  ]),
  buildableFolders: [.sources, .resources],
  dependencies: [
    .presentation(.appUI),
    .data(.liveSupports)
  ]
)
