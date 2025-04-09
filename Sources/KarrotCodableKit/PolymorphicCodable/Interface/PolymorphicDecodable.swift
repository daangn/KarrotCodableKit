//
//  PolymorphicDecodable.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/**
 A macro that enables polymorphic decoding support for types.

 This macro automatically implements the necessary components for polymorphic
 decoding by adding PolymorphicDecodableType conformance and generating
 appropriate CodingKeys.

 - Parameters:
   - identifier: The string value used to identify this specific type in polymorphic decoding.
   - codingKeyStyle: Specifies the naming convention to use when generating `CodingKeys`.
     Default is `.default` which preserves the original property names.
 */
@attached(extension, conformances: PolymorphicDecodableType, names: named(polymorphicIdentifier))
@attached(member, names: named(CodingKeys))
public macro PolymorphicDecodable(
  identifier: String,
  codingKeyStyle: CodingKeyStyle = .default
) = #externalMacro(module: "KarrotCodableKitMacros", type: "PolymorphicDecodableMacro")
