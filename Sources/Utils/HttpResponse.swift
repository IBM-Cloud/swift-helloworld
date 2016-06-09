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
import CloudFoundryEnv

public func generateHttpResponse(appEnv: AppEnv) -> String {
  var responseBody = "<html><body>Hello from Swift on Linux!" +
  "<br />" +
  "<br />"

  // Environment variables
  responseBody += "<table border=\"1\">" +
  "<tr><th>Environment Variable</th><th>Value</th></tr>"

  // Get environment variables
  let environmentVars = NSProcessInfo.processInfo().environment
  for (variable, value) in environmentVars {
    responseBody += "<tr><td>\(variable)</td><td>\(value)</td></tr>\n"
  }
  responseBody += "</table><br /><br />"

  // JSON object for App
  // This conditional is indeed odd... https://github.com/SwiftyJSON/SwiftyJSON/issues/205
  if appEnv.app.null == nil {
    responseBody += "<table border=\"1\">" +
    "<tr><th>App Property (JSON)</th><th>Value</th></tr>"

    for (variable, value) in appEnv.app {
      responseBody += "<tr><td>\(variable)</td><td>\(value.stringValue)</td></tr>\n"
    }

    responseBody += "</table>"
    responseBody += "<br /><br />"
  }

  // Get App object
  let app = appEnv.getApp()
  responseBody += "<table border=\"1\">"
  responseBody += "<tr><th colspan=\"2\">Application Environment Object</th></tr>\n"
  responseBody += "<tr><td>AppEnv</td><td>isLocal: \(appEnv.isLocal), port: \(appEnv.port), name: \(appEnv.name), bind: \(appEnv.bind), urls: \(appEnv.urls), app: \(appEnv.app), services: \(appEnv.services)</td></tr>\n"
  responseBody += "<tr><th colspan=\"2\">Application Object</th></tr>\n"
  responseBody += "<tr><td>App</td><td>\(app)</td></tr>\n"

  // Service objects
  let services = appEnv.getServices()
  responseBody += "<tr><th colspan=\"2\">Service Objects</th></tr>\n"
  if services.count > 0 {
    for (name, service) in services {
      responseBody += "<tr><td>\(name)</td><td>\(service)</td></tr>\n"
    }
  } else {
    responseBody += "<tr><td colspan=\"2\">[None]</td></tr>\n"
  }

  responseBody += "</table>"
  responseBody += "</html>"

  let httpResponse = "HTTP/1.0 200 OK\n" +
  "Content-Type: text/html\n" +
  "Content-Length: \(responseBody.length) \n\n" +
  responseBody

  return httpResponse
}
