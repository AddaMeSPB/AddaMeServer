// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "AddameServer",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.65.1"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.2.0"),
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "6.7.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.0"),
        .package(url: "https://github.com/vapor/apns.git", from: "1.0.1"),
        .package(url: "https://github.com/AddaMeSPB/AddaMeRouteHandlers.git", branch: "main"),
        .package(url: "https://github.com/AddaMeSPB/AddaSharedModels.git", branch: "route"),
//        .package(path: "../AddaMeRouteHandlers"),
//        .package(path: "../AddaSharedModels"),
        .package(url: "https://github.com/twof/VaporTwilioService.git", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "APNS", package: "apns"),
                .product(name: "Twilio", package: "VaporTwilioService"),
                .product(name: "MongoKitten", package: "MongoKitten"),
                .product(name: "AddaMeRouteHandlers", package: "AddaMeRouteHandlers"),
                .product(name: "AddaSharedModels", package: "AddaSharedModels"),
                
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(name: "Main", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
