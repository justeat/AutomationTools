// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "AutomationTools",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "AutomationTools-Core",
            targets: ["AutomationTools-Core"]),
        .library(
            name: "AutomationTools-Host",
            targets: ["AutomationTools-Host"])
    ],
    targets: [
        .target(
            name: "AutomationTools-Core",
            path: "AutomationTools/Classes/Core/"
        ),
        .target(
            name: "AutomationTools-Host",
            path: "AutomationTools/Classes/HostApp/"
        )
    ]
)
