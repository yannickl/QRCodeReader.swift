// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "QRCodeReader",
  products: [
    .library(name: "QRCodeReader", targets: ["QRCodeReader"]),
  ],
  targets: [
    .target(
      name: "QRCodeReader",
      dependencies: [],
      path: "Sources"),
  ]
)

