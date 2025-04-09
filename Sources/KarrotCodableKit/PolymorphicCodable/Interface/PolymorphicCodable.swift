//
//  PolymorphicCodable.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/**
 A macro that enables polymorphic coding support for types.

 This macro automatically implements the necessary components for polymorphic
 encoding and decoding by adding PolymorphicCodableType conformance and generating
 appropriate CodingKeys.

 - Parameters:
   - identifier: The string value used to identify this specific type in polymorphic coding.
   - codingKeyStyle: Specifies the naming convention to use when generating `CodingKeys`.
     Default is `.default` which preserves the original property names.
 */
@attached(extension, conformances: PolymorphicCodableType, names: named(polymorphicIdentifier))
@attached(member, names: named(CodingKeys))
public macro PolymorphicCodable(
  identifier: String,
  codingKeyStyle: CodingKeyStyle = .default
) = #externalMacro(module: "KarrotCodableKitMacros", type: "PolymorphicCodableMacro")
