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

 Each enum case must have exactly one associated value, and the type of that value must conform to `PolymorphicIdentifiable`.

 - Parameter identifierCodingKey: The key name in the JSON used to store the type identifier.
 */
@attached(extension, conformances: Codable, names: named(PolymorphicMetaCodingKey), named(init), named(encode))
public macro PolymorphicEnumCodable(
  identifierCodingKey: String
) = #externalMacro(module: "KarrotCodableKitMacros", type: "PolymorphicEnumCodableMacro")
