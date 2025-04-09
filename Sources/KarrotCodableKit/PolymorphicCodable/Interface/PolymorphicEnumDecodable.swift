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

 - Parameter identifierCodingKey: The key name in the JSON used to store the type identifier.
 */
@attached(extension, conformances: Decodable, names: named(PolymorphicMetaCodingKey), named(init))
public macro PolymorphicEnumDecodable(
  identifierCodingKey: String
) = #externalMacro(module: "KarrotCodableKitMacros", type: "PolymorphicEnumDecodableMacro")
