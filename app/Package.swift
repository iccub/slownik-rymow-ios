// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "app",
  platforms: [.iOS(.v15), .macOS(.v12)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "app", targets: ["app"]),
    .library(name: "Models", targets: ["Models"]),
    .library(name: "Views", targets: ["Views"]),
    .library(name: "Extensions", targets: ["Extensions"])
  ],
  dependencies: [
    .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.13.1"),
    .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "0.1.3")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "app",
      dependencies: [
        "Views"
      ]),
    .target(name: "Models", dependencies: [
      .product(name: "SQLite", package: "sqlite.swift")
    ]),
    .target(name: "Views", dependencies: [
      "Models",
      "Extensions",
      .product(name: "Introspect", package: "SwiftUI-Introspect")
    ]),
    .target(name: "Extensions"),
    .testTarget(
      name: "appTests",
      dependencies: ["app"]
    ),
  ]
)
