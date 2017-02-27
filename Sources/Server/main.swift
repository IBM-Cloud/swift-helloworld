/**
* Copyright IBM Corporation 2016
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

/**
* Creates a simple HTTP server that listens for incoming connections on port 9080.
* For each request receieved, the server simply sends a simple hello world message
* back to the client.
**/

#if os(Linux)
import Glibc
#else
import Darwin
#endif

import Foundation
import Socket
import Configuration
import CloudFoundryConfig
import Utils
import HeliumLogger
import LoggerAPI

// Disable all buffering on stdout
setbuf(stdout, nil)

// Main functionality
do {
  Log.logger = HeliumLogger()

  //let appEnv = try CloudFoundryEnv.getAppEnv()
  let manager = ConfigurationManager()
  manager.load(file: "config.json").load(.environmentVariables)
  //let appEnv = manager
  //let value = manager["path:to:configuration:value"]
  let httpResponse = generateHttpResponse(appEnv: manager)
  // Create server/listening socket
  var socket = try Socket.create()
  try socket.listen(on: appEnv.port, maxBacklogSize: 10)
  Log.verbose("Server is starting on \(appEnv.url).")
  Log.verbose("Server is listening on port: \(appEnv.port).\n")
  var counter = 0
  while true {
    // Replace the listening socket with the newly accepted connection...
    let clientSocket = try socket.acceptClientConnection()
    // Read data from client before writing to the socket
    var data = NSMutableData()
    let numberOfBytes = try clientSocket.read(into: data)
    counter = counter + 1
    Log.verbose("<<<<<<<<<<<<<<<<<<")
    Log.verbose("Request #: \(counter).")
    Log.verbose("Accepted connection from: \(clientSocket.remoteHostname) on port \(clientSocket.remotePort).")
    Log.verbose("Number of bytes receieved from client: \(numberOfBytes)")
    try clientSocket.write(from: httpResponse)
    clientSocket.close()
    Log.verbose("Sent http response to client...")
    Log.verbose(">>>>>>>>>>>>>>>>>>>")
  }
} catch {
  Log.error("Oops, something went wrong... Server did not start (or has died)!")
}
