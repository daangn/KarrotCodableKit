//
//  PolymorphicCodableStrategyProviding.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/**
 A macro for creating a polymorphic codable strategy.

 This macro generates a type-safe decoding strategy for polymorphic types based on an identifier
 field. It creates a strategy that can be used with different polymorphic decodable types
 to handle type-based deserialization. This functionality provides Swift implementation for the
 OpenAPI Specification's `oneOf` pattern, enabling type-safe polymorphic decoding.

 - Parameters:
   - identifierCodingKey: The key name in the JSON used to determine the concrete type.
      This corresponds to the `discriminator.propertyName` in OpenAPI Specification's oneOf definition.
      The default value for this property is `"type"`.
   - matchingTypes: An array of polymorphic types that this strategy will handle.
   - fallbackType: Optional type to use when no matching type is found. If nil, decoding will fail
                   when no matching type is found. The default value for this property is `nil`.
 */
@attached(peer, names: suffixed(CodableStrategy))
@attached(member, names: arbitrary)
public macro PolymorphicCodableStrategyProviding(
  identifierCodingKey: String = "type",
  matchingTypes: [PolymorphicDecodableType.Type],
  fallbackType: PolymorphicDecodableType.Type? = nil
) = #externalMacro(
  module: "KarrotCodableKitMacros",
  type: "PolymorphicCodableStrategyProvidingMacro"
)
