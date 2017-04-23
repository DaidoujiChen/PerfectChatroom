import PackageDescription

let package = Package(
    name: "PerfectChatroom",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),
        .Package(url:"https://github.com/PerfectlySoft/Perfect-WebSockets.git", majorVersion: 2)
    ]
)
