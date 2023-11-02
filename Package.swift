// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AddameServer",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.65.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.1.2"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.2.0"),
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "6.7.0"),
        .package(url: "https://github.com/orlandos-nl/MongoQueue.git", from: "0.1.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.0"),
        .package(url: "https://github.com/vapor/apns.git", from: "1.0.1"),
        .package(url: "https://github.com/pointfreeco/vapor-routing", from: "0.1.2"),
        .package(url: "https://github.com/AddaMeSPB/AddaSharedModels.git", branch: "CleanUpBackEndModel"),
//        .package(path: "../AddaSharedModels"),

        // Redis
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.3"),

        // Mailgun
        .package(url: "https://github.com/vapor-community/mailgun.git", from: "5.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "APNS", package: "apns"),
                .product(name: "MongoKitten", package: "MongoKitten"),
                .product(name: "MongoQueue", package: "MongoQueue"),
                .product(name: "AddaSharedModels", package: "AddaSharedModels"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                .product(name: "Mailgun", package: "mailgun"),
                .product(name: "VaporRouting", package: "vapor-routing")
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
