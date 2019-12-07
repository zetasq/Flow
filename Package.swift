// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "Flow",
  platforms: [
    .iOS(.v12)
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
      dependencies: ["FlowObjC", "Concrete"]
    ),
    .testTarget(
      name: "FlowTests",
      dependencies: ["FlowObjC", "Flow"]
    ),
  ]
)
