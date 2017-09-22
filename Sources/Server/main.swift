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
import Utils
import Socket

// Disable all buffering on stdout
setbuf(stdout, nil)

// Generate HTTP response for clients
func generateHttpResponse() -> String {
  let responseBody = "Hello from Swift on Linux!\n"
  let httpResponse = "HTTP/1.0 200 OK\n" +
  "Content-Type: text/plain; charset=UTF-8\n\n" +
  responseBody
  return httpResponse
}

// Main functionality
do {
  let (_, port) = parseAddress()
  let httpResponse = generateHttpResponse()
  // Create server/listening socket
  let socket = try Socket.create()
  try socket.listen(on: port, maxBacklogSize: 10)
  print("Server is starting...")
  print("Server is listening on port: \(port).\n")
  var counter = 0
  while true {
    // Replace the listening socket with the newly accepted connection...
    let clientSocket = try socket.acceptClientConnection()
    // Read data from client before writing to the socket
    let data = NSMutableData()
    let numberOfBytes = try clientSocket.read(into: data)
    counter += 1
    print("<<<<<<<<<<<<<<<<<<")
    print("Request #: \(counter).")
    print("Accepted connection from: \(clientSocket.remoteHostname) on port \(clientSocket.remotePort).")
    print("Number of bytes receieved from client: \(numberOfBytes)")
    try clientSocket.write(from: httpResponse)
    clientSocket.close()
    print("Sent http response to client...")
    print(">>>>>>>>>>>>>>>>>>>")
  }
} catch {
  print("Oops, something went wrong... Server did not start (or has died)!")
}
