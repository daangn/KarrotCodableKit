//
//  KeyedDecodingContainer+PolymorphicLossyArrayValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
  public func decode<T>(
    _: PolymorphicLossyArrayValue<T>.Type,
    forKey key: Key
  ) throws -> PolymorphicLossyArrayValue<T> where T: PolymorphicCodableStrategy {
    // Return empty array if key is missing
    guard contains(key) else {
      #if DEBUG
      let context = DecodingError.Context(
        codingPath: codingPath + [key],
        debugDescription: "Key not found but property is non-optional"
      )
      let error = DecodingError.keyNotFound(key, context)
      let decoder = try superDecoder(forKey: key)
      decoder.reportError(error)
      return PolymorphicLossyArrayValue(
        wrappedValue: [],
        outcome: .recoveredFrom(error, wasReported: true),
        results: []
      )
      #else
      return PolymorphicLossyArrayValue(wrappedValue: [], outcome: .keyNotFound)
      #endif
    }

    // Null, non-array values, and element failures are all recovered inside `init(from:)`.
    return try PolymorphicLossyArrayValue(from: superDecoder(forKey: key))
  }

  public func decodeIfPresent<T>(
    _: PolymorphicLossyArrayValue<T>.Type,
    forKey key: Self.Key
  ) throws -> PolymorphicLossyArrayValue<T>? where T: PolymorphicCodableStrategy {
    // Check if key exists
    guard contains(key) else {
      return nil
    }

    // Null, non-array values, and element failures are all recovered inside `init(from:)`.
    return try PolymorphicLossyArrayValue(from: superDecoder(forKey: key))
  }
}
