// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TechjaysQuickChat",
    platforms: [
        // Only add support for iOS 11 and up.
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TechjaysQuickChat",
            targets: ["TechjaysQuickChat"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        //        .package(url: "https://github.com/WeTransfer/Mocker.git", from: "2.0.0"),
        
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "6.0.0")),
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TechjaysQuickChat",
            dependencies: ["Kingfisher", .product(name: "FirebaseAuth", package: "Firebase"), .product(name: "FirebaseStorage", package: "Firebase"),  .product(name: "FirebaseFirestore", package: "Firebase")
            ],
            resources: [
                .process("GoogleService-Info.plist"),
                .process("Info.plist"),
                .copy("newMessage.wav")
            ]),
        .testTarget(
            name: "TechjaysQuickChatTests",
            dependencies: ["TechjaysQuickChat"]),
    ]
)
