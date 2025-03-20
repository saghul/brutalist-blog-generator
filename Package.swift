// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "bbg",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.3.1"),
        .package(url: "https://github.com/stencilproject/Stencil.git", branch: "master"),
    ],
    targets: [
        .executableTarget(
            name: "bbg",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "Stencil", package: "Stencil"),
            ],
            resources: [
                .embedInCode("Templates/base.html"),
                .embedInCode("Templates/index.html"),
                .embedInCode("Templates/post.html"),
                .embedInCode("Templates/main.css"),
                .embedInCode("Templates/rss.xml"),
            ]
        ),
    ]
)
