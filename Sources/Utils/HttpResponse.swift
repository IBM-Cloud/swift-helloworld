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

import Foundation
import Configuration
import CloudFoundryConfig

public func generateHttpResponse(configMgr: ConfigurationManager) -> String {
  var responseBody = "<html><body>Hello from Swift on Linux!" +
  "<br />" +
  "<br />"

  // Environment variables
  responseBody += "<table border=\"1\">" +
  "<tr><th>Environment Variable</th><th>Value</th></tr>"

  // Get environment variables
  //let environmentVars = ProcessInfo.processInfo.environment
  if let environmentVars = configMgr.getConfigs() as? [String : Any] {
    for (variable, value) in environmentVars {
      responseBody += "<tr><td>\(variable)</td><td>\(value)</td></tr>\n"
    }
  }
  responseBody += "</table><br /><br />"

  // JSON object for App
  if !configMgr.app.isEmpty {
    responseBody += "<table border=\"1\">" +
    "<tr><th>App Property (JSON)</th><th>Value</th></tr>"

    for (variable, value) in configMgr.app {
      let value = String(describing: value)
      responseBody += "<tr><td>\(variable)</td><td>\(value)</td></tr>\n"
    }

    responseBody += "</table>"
    responseBody += "<br /><br />"
  }

  // Get App object
  let app = configMgr.getApp()
  responseBody += "<table border=\"1\">"
  responseBody += "<tr><th colspan=\"2\">Application Environment Object</th></tr>\n"
  responseBody += "<tr><td>AppEnv</td><td>isLocal: \(configMgr.isLocal), port: \(configMgr.port), name: \(configMgr.name ??? "[N/A]"), bind: \(configMgr.bind), urls: \(configMgr.urls), app: \(app ??? "[N/A]"), services: \(configMgr.services)</td></tr>\n"
  responseBody += "<tr><th colspan=\"2\">Application Object</th></tr>\n"
  responseBody += "<tr><td>App</td><td>\(app ??? "[N/A]")</td></tr>\n"

  // Service objects
  let services = configMgr.getServices()
  responseBody += "<tr><th colspan=\"2\">Service Objects</th></tr>\n"
  if services.count > 0 {
    for (name, service) in services {
      responseBody += "<tr><td>\(name)</td><td>\(service)</td></tr>\n"
    }
  } else {
    responseBody += "<tr><td colspan=\"2\">[N/A]</td></tr>\n"
  }

  responseBody += "</table>"
  responseBody += "</html>"

  let httpResponse = "HTTP/1.0 200 OK\n" +
  "Content-Type: text/html; charset=UTF-8\n" +
  "Content-Length: \(responseBody.length) \n\n" +
  responseBody

  return httpResponse
}
