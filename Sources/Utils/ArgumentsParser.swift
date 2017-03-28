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

import Foundation

public func parseAddress() -> (String, Int) {
  let args = Array(ProcessInfo.processInfo.arguments[1..<ProcessInfo.processInfo.arguments.count])
  var port = 8080 // default port
  var ip = "0.0.0.0" // default ip
  if args.count == 2 && args[0] == "-bind" {
    let tokens = args[1].components(separatedBy: ":")
    if tokens.count == 2 {
      ip = tokens[0]
      if let portNumber = Int(tokens[1]) {
        port = portNumber
      }
    }
  }
  return (ip, port)
}
