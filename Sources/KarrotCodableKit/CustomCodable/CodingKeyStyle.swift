//
//  CodingKeyStyle.swift
//  KarrotCodableKit
//
//  Created by Elon on 11/12/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

import Foundation

/**
 Defines the style to use when converting property names to coding keys.

 This enum is used with `@CustomCodable` and `@PolymorphicCodable` property wrappers
 to control how Swift property names are mapped to and from JSON keys during encoding
 and decoding processes.

 - Note: When used with custom codable types, this style determines the transformation
         applied to property names when generating coding keys.
 */
public enum CodingKeyStyle {
  /// Converts property name to `snake_case` and uses it as CodingKey.
  case snakeCase
  /// Uses property name as is for CodingKey.
  case `default`
}
