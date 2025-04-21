//
//  PolymorphicEnumCodable.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/19/24.
//

import Foundation

/**
 A macro that makes enum types polymorphically codable.

 This macro adds Codable conformance to enum types, allowing them to be serialized and
 deserialized based on a type identifier. It generates the necessary coding keys,
 initializer, and encoding methods.

 Each enum case must have exactly one associated value, and the type of that value must conform
 to `PolymorphicIdentifiable`.

 - Parameters:
   - identifierCodingKey: The key name in the JSON used to store the type identifier.
      The default value for this property is `"type"`. This key is used to identify the specific
      case of the enum during
   - fallbackCaseName: The name of the `case` to use when the type identifier is not found.
      The default value for this property is `nil`. If this property is not provided, the macro will
      throw an error if the type identifier is not found.

 - Warning: When decoding falls back to the fallback case, during encoding the original `type` value
      will not be preserved. Instead, the `type` value of the fallback case will be used in the
      encoded output.
 */
@attached(
  extension,
  conformances: Codable,
  names: named(PolymorphicMetaCodingKey),
  named(init),
  named(encode)
)
public macro PolymorphicEnumCodable(
  identifierCodingKey: String = "type",
  fallbackCaseName: String? = nil
) = #externalMacro(module: "KarrotCodableKitMacros", type: "PolymorphicEnumCodableMacro")
