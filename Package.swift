// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Flow",
  platforms: [
    .iOS(.v12)
  ],
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "Flow",
      targets: ["FlowObjC", "Flow"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/zetasq/Concrete.git", .branch("master"))
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "FlowObjC",
      dependencies: ["Concrete"]
    ),
    .target(
      name: "Flow",
      dependencies: ["FlowObjC"]
    ),
    .testTarget(
      name: "FlowTests",
      dependencies: ["FlowObjC", "Flow"]
    ),
  ]
)
