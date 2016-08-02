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

/**
* JSON utilities.
*/
public struct JSONUtils {

  /**
  * Converts the speficied string to a JSON object.
  */
  public static func convertStringToJSON(text: String?) -> JSON? {
    let data = text?.data(using: NSUTF8StringEncoding)
    guard let nsData = data else {
      print("Could not generate JSON object from string: \(text)")
      return nil
    }
    let json = JSON(data: nsData)
    return json
  }

  /**
  * Converts a JSON array element contained in a JSON object to an array of Strings.
  * The fieldName argument should state the name of the JSON property that contains
  * the JSON array.
  */
  public static func convertJSONArrayToStringArray(json: JSON, fieldName: String) -> [String] {
    return json[fieldName].arrayValue.map { $0.stringValue }
  }
}
