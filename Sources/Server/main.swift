/**
* Copyright IBM Corporation 2016, 2017
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
* Creates a simple HTTP server that listens for incoming connections on port 8080.
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

// Main functionality
do {
  // Disable all buffering on stdout
  //setbuf(stdout, nil)
  HeliumLogger.use(LoggerMessageType.info)
  // Load configuration
  let configMgr = ConfigurationManager()
  configMgr.load(.environmentVariables)
  //let value = manager["path:to:configuration:value"]
  let httpResponse = generateHttpResponse(configMgr: configMgr)
  // Create server/listening socket
  var socket = try Socket.create()
  try socket.listen(on: configMgr.port, maxBacklogSize: 10)
  Log.info("Server is starting on \(configMgr.url).")
  Log.info("Server is listening on port: \(configMgr.port).\n")
  var counter = 0
  while true {
    // Replace the listening socket with the newly accepted connection...
    let clientSocket = try socket.acceptClientConnection()
    // Read data from client before writing to the socket
    var data = NSMutableData()
    let numberOfBytes = try clientSocket.read(into: data)
    counter += 1
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
  Log.error("Oops, something went wrong... Server did not start (or died)!")
}
