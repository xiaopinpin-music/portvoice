// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PortVoice",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PortVoice", targets: ["PortVoice"])
    ],
    targets: [
        .executableTarget(
            name: "PortVoice",
            path: "Sources/PortVoice"
        )
    ]
)
