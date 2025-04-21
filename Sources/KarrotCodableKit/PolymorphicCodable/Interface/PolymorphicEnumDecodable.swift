//
//  PolymorphicEnumDecodable.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/**
 A macro that makes enum types polymorphically decodable.

 This macro adds Decodable conformance to enum types, allowing them to be deserialized
 based on a type identifier. It generates the necessary coding keys and initializer methods.

 Each enum case must have exactly one associated value, and the type of that value must conform to
 `PolymorphicIdentifiable`.

 - Parameters:
   - identifierCodingKey: The key name in the JSON used to store the type identifier.
      The default value for this property is `"type"`. This key is used to identify the specific
      case of the enum during
   - fallbackCaseName: The name of the `case` to use when the type identifier is not found.
      The default value for this property is `nil`. If this property is not provided, the macro will
      throw an error if the type identifier is not found.
 */
@attached(extension, conformances: Decodable, names: named(PolymorphicMetaCodingKey), named(init))
public macro PolymorphicEnumDecodable(
  identifierCodingKey: String = "type",
  fallbackCaseName: String? = nil
) = #externalMacro(module: "KarrotCodableKitMacros", type: "PolymorphicEnumDecodableMacro")
