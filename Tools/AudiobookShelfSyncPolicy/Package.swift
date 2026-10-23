// swift-tools-version: 5.9
import PackageDescription

// Deliberately not linked into the iOS app. No network or persistence dependencies.
let package = Package(
  name: "AudiobookShelfSyncPolicy",
  products: [.library(name: "AudiobookShelfSyncPolicy", targets: ["AudiobookShelfSyncPolicy"])],
  targets: [
    .target(name: "AudiobookShelfSyncPolicy"),
    .testTarget(name: "AudiobookShelfSyncPolicyTests", dependencies: ["AudiobookShelfSyncPolicy"])
  ]
)
