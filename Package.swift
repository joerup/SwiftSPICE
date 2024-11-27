// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftSPICE",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "SwiftSPICE",
            targets: ["SwiftSPICE"]
        ),
        .executable(
            name: "SwiftSPICEExecutable",
            targets: ["SwiftSPICEExecutable"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "CSPICE",
            path: "Sources/SwiftSPICE/CSPICE.xcframework"
        ),
        .target(
            name: "SwiftSPICE",
            dependencies: ["CSPICE"],
            path: "Sources/SwiftSPICE",
            exclude: ["CSPICE.xcframework"]
        ),
        .executableTarget(
            name: "SwiftSPICEExecutable",
            dependencies: ["SwiftSPICE"],
            path: "Sources/SwiftSPICEExecutable",
            resources: [
                .process("Resources/de432s.bsp")
            ]
        ),
        .testTarget(
            name: "SwiftSPICETests",
            dependencies: ["SwiftSPICE"],
            resources: [
                .process("Resources/de432s.bsp")
            ]
        ),
    ]
)
