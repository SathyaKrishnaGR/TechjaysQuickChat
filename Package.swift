// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TechjaysQuickChat",
    platforms: [
        // Only add support for iOS 11 and up.
        .iOS(.v13)
        
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TechjaysQuickChat",
            targets: ["TechjaysQuickChat"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.3")),
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "4.0.0")),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TechjaysQuickChat",
            dependencies: ["Alamofire", "Starscream"
            ]),
        .testTarget(
            name: "TechjaysQuickChatTests",
            dependencies: ["TechjaysQuickChat"]),
    ]
)
