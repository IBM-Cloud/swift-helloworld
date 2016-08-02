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
import SwiftyJSON

public struct AppEnv {

  public let isLocal: Bool
  public let port: Int
  public let name: String?
  public let bind: String
  public let urls: [String]
  public let url: String
  public let app: JSON
  public let services: JSON

  /**
  * The vcap option property is ignored if not running locally.
  */
  public init(options: JSON) throws {
    // NSProcessInfo.processInfo().environment returns [String : String]
    let environmentVars = NSProcessInfo.processInfo().environment
    let vcapApplication = environmentVars["VCAP_APPLICATION"]
    isLocal = (vcapApplication == nil)

    // Get app
    app = try AppEnv.parseEnvVariable(isLocal: isLocal, environmentVars: environmentVars,
      variableName: "VCAP_APPLICATION", varibleType: "application", options: options)

    // Get services
    services = try AppEnv.parseEnvVariable(isLocal: isLocal, environmentVars: environmentVars,
      variableName: "VCAP_SERVICES", varibleType: "services", options: options)

    // Get port
    port = try AppEnv.parsePort(environmentVars: environmentVars, app: app)

    // Get name
    name = AppEnv.parseName(app: app, options: options)

    // Get bind (IP address of the application instance)
    bind = app["host"].string ?? "0.0.0.0"

    // Get urls
    urls = AppEnv.parseURLs(isLocal: isLocal, app: app, port: port, options: options)
    url = urls[0]
  }

  /**
  * Returns an App object.
  */
  public func getApp() -> App? {
    // Get limits
    let limits: App.Limits
    if let memory = app["limits"]["mem"].int,
       let disk = app["limits"]["disk"].int,
       let fds = app["limits"]["fds"].int {
         limits = App.Limits(memory: memory, disk: disk, fds: fds)
    } else {
      return nil
    }

    // Get uris
    let uris = JSONUtils.convertJSONArrayToStringArray(json: app, fieldName: "uris")
    // Create DateUtils instance
    let dateUtils = DateUtils()

    guard
      let name = app["application_name"].string,
      let id = app["application_id"].string,
      let version = app["version"].string,
      let instanceId = app["instance_id"].string,
      let instanceIndex = app["instance_index"].int,
      let port = app["port"].int,
      let startedAt: NSDate = dateUtils.convertStringToNSDate(dateString: app["started_at"].string),
      let spaceId = app["space_id"].string else {
        return nil
      }

    let startedAtTs = startedAt.timeIntervalSince1970

    // App instance should only be created if all required variables exist
    let appObj = App(id: id, name: name, uris: uris, version: version,
      instanceId: instanceId, instanceIndex: instanceIndex,
      limits: limits, port: port, spaceId: spaceId,
      startedAtTs: startedAtTs, startedAt: startedAt)
    return appObj
  }

  /**
  * Returns all services bound to the application in a dictionary. The key in
  * the dictionary is the name of the service, while the value is a Service
  * object that contains all the properties for the service.
  */
  public func getServices() -> [String:Service] {
    var results: [String:Service] = [:]
    for (_, servs) in services {
      for service in servs.arrayValue { // as! [[String:AnyObject]] {
        // A service must have a name and a label
        if let name: String = service["name"].string,
           let label: String = service["label"].string {
          let tags = JSONUtils.convertJSONArrayToStringArray(json: service, fieldName: "tags")
          results[name] =
            Service(name: name, label: label, plan: service["plan"].string, tags: tags, credentials: service["credentials"])
        }
      }
    }
    return results
  }

  /**
  * Returns a Service object with the properties for the specified Cloud Foundry
  * service. The spec parameter should be the name of the service
  * or a regex to look up the service. If there is no service that matches the
  * spec parameter, this method returns nil.
  */
  public func getService(spec: String) -> Service? {
    let services = getServices()
    if let service = services[spec] {
      return service
    }

    do {
      let regex = try NSRegularExpression(pattern: spec, options: NSRegularExpressionOptions.caseInsensitive)
      for (name, serv) in services {
        let numberOfMatches = regex.numberOfMatches(in: name, options: [], range: NSMakeRange(0, name.characters.count))
        if numberOfMatches > 0 {
          return serv
        }
      }
    } catch let error as NSError {
      print("Error code: \(error.code)")
    }
  	return nil
  }

  /**
  * Returns a URL generated from VCAP_SERVICES for the specified service or nil
  * if service is not found. The spec parameter should be the name of the
  * service or a regex to look up the service.
  *
  * The replacements parameter is a JSON object with the properties found in
  * Foundation's NSURLComponents class.
  */
  public func getServiceURL(spec: String, replacements: JSON?) -> String? {
    var substitutions: JSON = replacements ?? [:]
    let service = getService(spec: spec)
    guard let credentials = service?.credentials else {
      return nil
    }

    guard let url: String =
      credentials[substitutions["url"].string ?? "url"].string ?? credentials["uri"].string
      else {
      return nil
    }

    substitutions.dictionaryObject?["url"] = nil
    guard let parsedURL = NSURLComponents(string: url) else {
      return nil
    }

    // Set replacements in a predefined order
    // Before, we were just iterating over the keys in the JSON object,
    // but unfortunately the order of the keys returned were different on
    // OS X and Linux, which resulted in different outcomes.
    if let user = substitutions["user"].string {
       parsedURL.user = user
    }
    if let password = substitutions["password"].string {
      parsedURL.password = password
    }
    if let port = substitutions["port"].number {
      parsedURL.port = port
    }
    if let host = substitutions["host"].string {
      parsedURL.host = host
    }
    if let scheme = substitutions["scheme"].string {
      parsedURL.scheme = scheme
    }
    if let query = substitutions["query"].string {
      parsedURL.query = query
    }
    if let queryItems = substitutions["queryItems"].array {
      var urlQueryItems: [NSURLQueryItem] = []
      for queryItem in queryItems {
        if let name = queryItem["name"].string {
          let urlQueryItem = NSURLQueryItem(name: name, value: queryItem["value"].string)
          urlQueryItems.append(urlQueryItem)
        }
      }
      if urlQueryItems.count > 0 {
        parsedURL.queryItems = urlQueryItems
      }
    }
    // These are being ignored at the moment
    // if let fragment = substitutions["fragment"].string {
    //   parsedURL.fragment = fragment
    // }
    // if let path = substitutions["path"].string {
    //   parsedURL.path = path
    // }
    return parsedURL.string
  }

  /**
  * Returns a JSON object that contains the credentials for the specified
  * Cloud Foundry service. The spec parameter should be the name of the service
  * or a regex to look up the service. If there is no service that matches the
  * spec parameter, this method returns nil. In the case there is no credentials
  * property for the specified service, an empty JSON is returned.
  */
  public func getServiceCreds(spec: String) -> JSON? {
    guard let service = getService(spec: spec) else {
      return nil
    }
    if let credentials = service.credentials {
      return credentials
    } else {
      return [:]
    }
  }

  /**
  * Static method for parsing VCAP_APPLICATION and VCAP_SERVICES.
  */
  private static func parseEnvVariable(isLocal: Bool, environmentVars: [String:String],
    variableName: String, varibleType: String, options: JSON) throws
    -> JSON {
    if isLocal {
      let envVariable = options["vcap"][varibleType]
      if envVariable.null != nil {
        return [:]
      }
      return envVariable
    } else {
      if let json = JSONUtils.convertStringToJSON(text: environmentVars[variableName]) {
        return json
      }
      throw CloudFoundryEnvError.InvalidValue("Environment variable \(variableName) is not a valid JSON string!")
    }
  }

  /**
  * Static method for parsing the port number.
  */
  private static func parsePort(environmentVars: [String:String], app: JSON) throws -> Int {
    let portString: String = environmentVars["PORT"] ?? environmentVars["CF_INSTANCE_PORT"] ??
      environmentVars["VCAP_APP_PORT"] ?? "8090"

    // TODO: Are there any benefits in implementing logic similar to ports.getPort() (npm module)...?
    // if portString == nil {
    //   if app["name"].string == nil {
    //     portString = "8090"
    //   }
    //   //portString = "" + (ports.getPort(appEnv.name));
    //   portString = "8090"
    // }
    //let number: Int? = (portString != nil) ? Int(portString!) : nil

    if let number = Int(portString) {
      return number
    } else {
      throw CloudFoundryEnvError.InvalidValue("Invalid PORT value: \(portString)")
    }
  }

  /**
  * Static method for parsing the name for the application.
  */
  private static func parseName(app: JSON, options: JSON) -> String? {
    let name: String? = options["name"].string ?? app["name"].string
    // TODO: Add logic for parsing manifest.yml to get name
    // https://github.com/behrang/YamlSwift
    // http://stackoverflow.com/questions/24097826/read-and-write-data-from-text-file
    return name
  }

  /**
  * Static method for parsing the URLs for the application.
  */
  private static func parseURLs(isLocal: Bool, app: JSON, port: Int,
    options: JSON) -> [String] {
    var uris: [String] = JSONUtils.convertJSONArrayToStringArray(json: app, fieldName: "uris")
    if isLocal {
      uris = ["localhost:\(port)"]
    } else {
      if (uris.count == 0) {
        uris = ["localhost"]
      }
    }

    let scheme: String = options["protocol"].string ?? (isLocal ? "http" : "https")
    var urls: [String] = []
    for uri in uris {
       urls.append("\(scheme)://\(uri)");
    }
    return urls
  }
}
