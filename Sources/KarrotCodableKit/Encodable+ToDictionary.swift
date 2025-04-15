//
//  Encodable+ToDictionary.swift
//  KarrotCodableKit
//
//  Created by Kanghoon Oh on 7/10/23.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension Encodable {
  /** Converts an `Encodable` to dictionary.

    This method encodes the object using `JSONEncoder` and then converts the resulting data
    to a dictionary using `JSONSerialization`.

    - Returns: A dictionary with string keys and any values that represents the encoded object.
    - Throws: An error if the encoding fails, or if the encoded data cannot be converted to a dictionary.
   */
  public func toDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(
      with: data,
      options: .fragmentsAllowed
    ) as? [String: Any]
    else {
      throw NSError(domain: "JSONSerialization Failed", code: 0)
    }
    return dictionary
  }
}
