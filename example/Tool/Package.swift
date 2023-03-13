// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Tool",
    platforms: [.macOS(.v13)],
    dependencies: [
        // .package(url: "https://github.com/kouki-dan/XLocalizableLinter.git", from: "0.1.0"),
        .package(path: "../../"),
    ],
    targets: [
      .target(name: "Tool", path: "")
    ]
)
