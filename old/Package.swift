// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// import PackageDescription

// let package = Package(
//     name: "screenshot-auto-renamer",
//     targets: [
//         // Targets are the basic building blocks of a package, defining a module or a test suite.
//         // Targets can depend on other targets in this package and products from dependencies.
//         .executableTarget(
//             name: "screenshot-auto-renamer"),
//     ]
// )

// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "screenshot-auto-renamer",
    products: [
        .executable(
            name: "screenshot-auto-renamer",
            targets: ["App"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: ["Screenshot"]
        ),
        .target(
            name: "Screenshot",
            dependencies: []
        )
    ]
)
