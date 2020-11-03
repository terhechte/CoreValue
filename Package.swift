// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "CoreValue",
  platforms: [
    .iOS(.v9),
    .macOS(.v10_10)
  ],
  products: [
    .library(
      name: "CoreValue",
      targets: ["CoreValue"]
    ),
    .library(
      name: "CoreValue-Static",
      type: .static,
      targets: ["CoreValue"]
    ),
    .library(
      name: "CoreValue-Dynamic",
      type: .dynamic,
      targets: ["CoreValue"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "CoreValue",
      dependencies: [],
      path: "./CoreValue",
      exclude: ["Info.plist"],
      publicHeadersPath: "./CoreValue"
    )
  ]
)
