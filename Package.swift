// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "KarrotCodableKit",
  platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
  products: [
    .library(
      name: "KarrotCodableKit",
      targets: ["KarrotCodableKit"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.0.0"..<"602.0.0"),
  ],
  targets: [
    .target(
      name: "KarrotCodableKit",
      dependencies: ["KarrotCodableKitMacros"]
    ),
    .macro(
      name: "KarrotCodableKitMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "KarrotCodableKitTests",
      dependencies: [
        "KarrotCodableKit",
      ]
    ),
    .testTarget(
      name: "KarrotCodableMacrosTests",
      dependencies: [
        "KarrotCodableKitMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
