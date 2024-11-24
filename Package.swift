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
        // C target for CSPICE library with headers
        .target(
            name: "CSPICE",
            path: "Sources/cspice",
            publicHeadersPath: "include",
            linkerSettings: [
                .unsafeFlags(["-L", "Sources/cspice", "-lcspice"])
            ]
        ),
        // Swift target that depends on the C target
        .target(
            name: "SwiftSPICE",
            dependencies: ["CSPICE"],
            resources: [
                .process("Resources/de432s.bsp")
            ]
        ),
        .executableTarget(
            name: "SwiftSPICEExecutable",
            dependencies: ["SwiftSPICE"]
        ),
        .testTarget(
            name: "SwiftSPICETests",
            dependencies: ["SwiftSPICE"]
        ),
    ]
)
