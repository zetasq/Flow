// swift-tools-version:6.2

import PackageDescription

let package = Package(
  name: "Flow",
  platforms: [
    .iOS(.v26), .macOS(.v26)
  ],
  products: [
    .library(
      name: "Flow",
      targets: ["FlowObjC", "Flow"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/zetasq/Concrete.git", branch: "main")
  ],
  targets: [
    .target(
      name: "FlowObjC",
      dependencies: ["Concrete"]
    ),
    .target(
      name: "Flow",
      dependencies: ["FlowObjC", "Concrete"],
			exclude: [
				"Documentation/"
			]
    ),
    .testTarget(
      name: "FlowTests",
      dependencies: ["FlowObjC", "Flow"]
    ),
  ]
)
