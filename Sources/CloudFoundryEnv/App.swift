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

 /**
 * See https://docs.run.pivotal.io/devguide/deploy-apps/environment-variable.html#VCAP-APPLICATION.
 */
public struct App {

  public struct Limits {
    let memory: Int
    let disk: Int
    let fds: Int

    public init(memory: Int, disk: Int, fds: Int) {
      self.memory = memory
      self.disk = disk
      self.fds = fds
    }
  }

  public let id: String
  public let name: String
  public let uris: [String]
  public let version: String
  public let instanceId: String
  public let instanceIndex: Int
  public let limits: Limits
  public let port: Int
  public let spaceId: String
  public let startedAtTs: NSTimeInterval
  public let startedAt: NSDate

  /**
  * Constructor.
  */
  public init(id: String, name: String, uris: [String], version: String,
    instanceId: String, instanceIndex: Int, limits: Limits, port: Int,
    spaceId: String, startedAtTs: NSTimeInterval, startedAt: NSDate) {

    self.id = id
    self.name = name
    self.uris = uris
    self.version = version
    self.instanceId = instanceId
    self.instanceIndex = instanceIndex
    self.limits = limits
    self.port = port
    self.spaceId = spaceId
    self.startedAtTs = startedAtTs
    self.startedAt = startedAt
  }
}
