//
//  Encodable+ToDictionary.swift
//  KarrotCodableKit
//
//  Created by Kanghoon Oh on 7/10/23.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension Encodable {
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
