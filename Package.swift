// swift-tools-version: 5.9
// This Package.swift is provided for reference if using Swift Package Manager.
// The primary project is the Xcode project (D426 Mastery.xcodeproj).

import PackageDescription

let package = Package(
    name: "D426Mastery",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "D426Mastery", targets: ["D426Mastery"])
    ],
    targets: [
        .target(
            name: "D426Mastery",
            path: "D426 Mastery",
            linkerSettings: [
                .linkedLibrary("sqlite3")
            ]
        )
    ]
)
