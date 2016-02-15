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
import Utils

// Create server socket
let address = parseAddress()
let server_sockfd = createSocket(address)
// Listen on socket with queue of 5
listen(server_sockfd, 5)
var active_fd_set = fd_set()
print("Server is listening on port: \(address.port)\n")

// Initialize the set of active sockets
fdSet(server_sockfd, set: &active_fd_set)

let FD_SETSIZE = Int32(1024)

let httpResponse = "HTTP/1.0 200 OK\n" +
  "Content-Type: text/html\n\n" +
  "<html><body>Hello from Swift on Linux!</body></html>"

var clientname = sockaddr_in()
while true {
  // Block until input arrives on one or more active sockets
  var read_fd_set = active_fd_set;
  select(FD_SETSIZE, &read_fd_set, nil, nil, nil)
  // Service all the sockets with input pending
  for i in 0..<FD_SETSIZE {
    if fdIsSet(i,set: &read_fd_set) {
      if i == server_sockfd {
        // Connection request on original socket
        var size = sizeof(sockaddr_in)
        // Accept request and assign socket
        withUnsafeMutablePointers(&clientname, &size) { up1, up2 in
          var client_sockfd = accept(server_sockfd,
            UnsafeMutablePointer(up1),
            UnsafeMutablePointer(up2))
            print("Received connection request from client: " + String(inet_ntoa (clientname.sin_addr)) + ", port " + String(UInt16(clientname.sin_port).bigEndian))
            fdSet(client_sockfd, set: &active_fd_set)
        }
      }
      else {
        // Send HTTP response back to client
        write(i, httpResponse, httpResponse.characters.count)
        // Close client socket
        close(i)
        fdClr(i, set: &active_fd_set)
      }
    }
  }
}
