//
//  Diagnostics.swift
//  KarrotCodableKit
//
//  Created by Elon on 12/27/23.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

import Foundation

enum CodableKitError: Error, CustomStringConvertible {
  case cannotApplyToEnum
  case message(String)

  var description: String {
    switch self {
    case .cannotApplyToEnum:
      return "`@CustomCodable`, `@CustomEncodable`, `@CustomDecodable` cannot be applied to enum"
    case .message(let message):
      return message
    }
  }
}
