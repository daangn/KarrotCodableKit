//
//  PolymorphicCodableError.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

public enum PolymorphicCodableError: LocalizedError {
  /// Error thrown when no matching type is found for the given polymorphic type identifier.
  /// - Parameter String: The polymorphic type identifier being searched for.
  case unableToFindPolymorphicType(String)

  /// Error thrown when a decoded value cannot be cast to the specified type.
  /// - Parameters:
  ///   - decoded: The decoded value.
  ///   - into: The name of the type to cast into.
  case unableToCast(decoded: PolymorphicDecodableType, into: String)

  /// Error thrown when a value cannot be represented as PolymorphicEncodable for encoding.
  /// - Parameter String: The value to be encoded.
  case unableToRepresentAsPolymorphicForEncoding(String)

  public var errorDescription: String? {
    switch self {
    case .unableToFindPolymorphicType(let polymorphicTypeIdentifier):
      "No matching type found for polymorphic type identifier \"\(polymorphicTypeIdentifier)\"."
    case .unableToCast(let decodeValue, let into):
      "Unable to cast decoded value '\(decodeValue)' to type '\(into)'."
    case .unableToRepresentAsPolymorphicForEncoding(let encodeValue):
      "Unable to cast value '\(encodeValue)' to PolymorphicEncodable for encoding."
    }
  }
}
