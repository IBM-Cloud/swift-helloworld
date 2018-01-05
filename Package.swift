// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

/**
 * Copyright IBM Corporation 2016, 2017, 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import PackageDescription

let package = Package(
    name: "HelloWorldSwift",
    products: [
        .executable(
            name: "Server",
            targets: ["Server", "Utils"])
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/CloudEnvironment.git", .upToNextMajor(from: "5.1.0")),
        .package(url: "https://github.com/IBM-Swift/BlueSocket.git", .upToNextMajor(from: "0.0.0")),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "Server",
            dependencies: ["Utils", "CloudEnvironment", "Socket", "HeliumLogger"]),
        .target(
            name: "Utils",
            dependencies: ["CloudEnvironment"])
    ]
)
