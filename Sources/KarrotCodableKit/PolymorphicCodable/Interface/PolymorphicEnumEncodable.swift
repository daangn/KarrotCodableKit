//
//  PolymorphicEnumEncodable.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//

import Foundation

/**
 A macro that makes enum types polymorphically encodable.

 This macro adds Encodable conformance to enum types, allowing them to be serialized
 based on a type identifier. It generates the necessary coding keys and encoding methods.

 Each enum case must have exactly one associated value, and the type of that value must conform to `PolymorphicIdentifiable`.

 - Parameter identifierCodingKey: The key name in the JSON used to store the type identifier.
 */
@attached(extension, conformances: Encodable, names: named(PolymorphicMetaCodingKey), named(encode))
public macro PolymorphicEnumEncodable(
  identifierCodingKey: String
) = #externalMacro(module: "KarrotCodableKitMacros", type: "PolymorphicEnumEncodableMacro")
