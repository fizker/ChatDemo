// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "ChatDemoServer",
	platforms: [
		.macOS(.v12),
	],
	products: [
		.executable(
			name: "ChatDemoServer",
			targets: [
				"ChatServer",
			]
		),
	],
	dependencies: [
		.package(url: "https://github.com/vapor/vapor.git", from: "4.62.1"),
		.package(url: "https://github.com/vapor/fluent.git", from: "4.4.0"),
		.package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.2.0"),
		.package(url: "https://github.com/fizker/swift-server-sent-event-models.git", from: "0.0.1"),
	],
	targets: [
		.executableTarget(
			name: "ChatServer",
			dependencies: [
				.product(name: "Fluent", package: "fluent"),
				.product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
				.product(name: "Vapor", package: "vapor"),
				.product(name: "ServerSentEventModels", package: "swift-server-sent-event-models"),
			],
			swiftSettings: [
				// Enable better optimizations when building in Release configuration. Despite the use of
				// the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
				// builds. See <https://github.com/swift-server/guides#building-for-production> for details.
				.unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
			]
		),
	]
)
