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
            path: "Frameworks/CSPICE.xcframework"
        ),
        .target(
            name: "CSPICEExtensions",
            path: "Frameworks/CSPICEExtensions",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("Headers")
            ]
        ),
        .target(
            name: "SwiftSPICE",
            dependencies: ["CSPICE", "CSPICEExtensions"],
            path: "Sources/SwiftSPICE"
        ),
        .executableTarget(
            name: "SwiftSPICEExecutable",
            dependencies: ["SwiftSPICE"],
            path: "Sources/SwiftSPICEExecutable",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SwiftSPICETests",
            dependencies: ["SwiftSPICE"],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
