// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "Flow",
  platforms: [
		.iOS(.v13), .macOS(.v10_12)
  ],
  products: [
    .library(
      name: "Flow",
      targets: ["FlowObjC", "Flow"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/zetasq/Concrete.git", .branch("master"))
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
