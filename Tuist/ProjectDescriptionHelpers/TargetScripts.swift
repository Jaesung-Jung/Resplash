import ProjectDescription

extension TargetScript {
  public static let swiftlint = TargetScript.pre(
    script:
      """
      if [ -d "$HOME/.local/share/mise/shims" ]; then
          export PATH="$HOME/.local/share/mise/shims:$PATH"
      fi

      SWIFTLINT_PATH=$(which swiftlint)
      SWIFTLINT_CONFIG_PATH="${WORKSPACE_DIR%}/swiftlint.yml"

      if [ -n "$(which swiftlint)" ]; then
        swiftlint --config "$SWIFTLINT_CONFIG_PATH"
      else
        echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
      fi
      """,
    name: "SwiftLint",
    basedOnDependencyAnalysis: false
  )
}
