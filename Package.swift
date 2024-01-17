// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "swift-json",
	platforms: [
		.macOS(.v10_13),
		.iOS(.v11),
		.tvOS(.v11),
		.watchOS(.v4),
	],
	products: [
		.library(name: "SwiftJSON", targets: ["SwiftJSON"]),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "SwiftJSON",
			dependencies: []
		),
	]
)
