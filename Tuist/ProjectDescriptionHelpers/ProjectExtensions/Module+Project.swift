import Foundation
import ProjectDescription

extension Project {
  public static func module<M: Module>(
    type: M.Type,
    packages: [Package] = [],
    targets: [M.Target] = M.Target.allCases,
    destinations: (M.Target) -> Destinations = { _ in .defaultDestinations},
    infoPlist: (M.Target) -> InfoPlist = { _ in .default },
    scripts: (M.Target) -> [TargetScript] = { _ in [] },
    dependencies: (M.Target) -> [TargetDependency],
    testDependencies: (M.Target) -> [TargetDependency] = { _ in [] }
  ) -> Project where M.Target.AllCases == [M.Target] {
    var projectTargets: [Target] = []
    for target in targets {
      let defaultTarget = Target.target(
        name: "\(target)",
        destinations: destinations(target),
        product: Environment.isDevelopment ? .framework : .staticFramework,
        productName: "\(ProjectConfig.name)\(target)",
        bundleId: ProjectConfig.bundleIdentifier(
          M.name.lowercased(),
          target.description.lowercased()
        ),
        deploymentTargets: ProjectConfig.deploymentTargets,
        infoPlist: infoPlist(target),
        buildableFolders: [.sources(M(target: target))],
        scripts: scripts(target) + [.swiftlint],
        dependencies: dependencies(target)
      )
      projectTargets.append(defaultTarget)

      let path = "\(FileManager.default.currentDirectoryPath)/Projects/\(M.name)/Tests/\(defaultTarget.name)Tests"
      if FileManager.default.fileExists(atPath: path) {
        let testTarget = Target.target(
          name: "\(defaultTarget.name)Tests",
          destinations: defaultTarget.destinations,
          product: .unitTests,
          productName: defaultTarget.productName.map { "\($0)Tests" },
          bundleId: "\(defaultTarget.bundleId).tests",
          deploymentTargets: defaultTarget.deploymentTargets,
          infoPlist: .default,
          buildableFolders: [.tests(M(target: target))],
          scripts: [.swiftlint],
          dependencies: [.module(M(target: target))] + testDependencies(target)
        )
        projectTargets.append(testTarget)
      }
    }
    return Project(
      name: M.name,
      options: .projectDefault {
        $0.automaticSchemesOptions = .enabled(
          targetSchemesGrouping: .byNameSuffix(
            build: [""],
            test: ["Tests"],
            run: []
          )
        )
      },
      packages: packages,
      settings: .projectDefault(),
      targets: projectTargets,
      fileHeaderTemplate: """
      
      //  ___FILENAME___
      //
      //  Copyright © 2025 Jaesung Jung. All rights reserved.
      //
      //  Permission is hereby granted, free of charge, to any person obtaining a copy
      //  of this software and associated documentation files (the "Software"), to deal
      //  in the Software without restriction, including without limitation the rights
      //  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      //  copies of the Software, and to permit persons to whom the Software is
      //  furnished to do so, subject to the following conditions:
      //
      //  The above copyright notice and this permission notice shall be included in
      //  all copies or substantial portions of the Software.
      //
      //  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      //  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      //  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      //  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      //  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      //  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      //  THE SOFTWARE.
      """
    )
  }
}
