// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSPICE",
    products: [
        .library(
            name: "SwiftSPICE",
            targets: ["SwiftSPICE"]
        ),
        .executable(
            name: "SwiftSPICEExecutable",
            targets: ["SwiftSPICEExecutable"]
        ),
    ],
    targets: [
        .target(
            name: "CSPICE",
            path: "Sources/cspice",
            publicHeadersPath: "include",
            linkerSettings: [
                .unsafeFlags(["-L", "Sources/cspice", "-lcspice"])
            ]
        ),
        .target(
            name: "SwiftSPICE",
            dependencies: ["CSPICE"]
        ),
        .executableTarget(
            name: "SwiftSPICEExecutable",
            dependencies: ["SwiftSPICE"],
            resources: [
                .process("Resources/de432s.bsp")
            ]
        ),
        .testTarget(
            name: "SwiftSPICETests",
            dependencies: ["SwiftSPICE"]
        ),
    ]
)
