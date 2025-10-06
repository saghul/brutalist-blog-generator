// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "brutalist-blog-generator",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.3.1"),
        .package(url: "https://github.com/stencilproject/Stencil.git", branch: "master"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.10.0"),
    ],
    targets: [
        .executableTarget(
            name: "bbg",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "BBGCore",
            ]
        ),
        .target(
            name: "BBGCore",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "Stencil", package: "Stencil"),
                .product(name: "Hummingbird", package: "hummingbird"),
            ],
            resources: [
                .embedInCode("Templates/base.html"),
                .embedInCode("Templates/index.html"),
                .embedInCode("Templates/post.html"),
                .embedInCode("Templates/page.html"),
                .embedInCode("Templates/main.css"),
                .embedInCode("Templates/rss.xml"),
            ]
        ),
        .testTarget(
            name: "BBGCoreTests",
            dependencies: ["BBGCore"]
        )
    ]
)
