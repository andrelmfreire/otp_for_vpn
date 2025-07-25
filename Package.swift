// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OTPAuthenticator",
    platforms: [
        .macOS(.v11)
    ],
    targets: [
        .executableTarget(
            name: "OTPAuthenticator",
            path: "OTPAuthenticator"
        )
    ]
) 