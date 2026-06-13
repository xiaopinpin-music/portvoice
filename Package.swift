// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PortVoice",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "PortVoice", targets: ["PortVoice"])
    ],
    targets: [
        .executableTarget(
            name: "PortVoice",
            path: "Sources/PortVoice",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
