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

    // Check if value is null
    if try decodeNil(forKey: key) {
      #if DEBUG
      let context = DecodingError.Context(
        codingPath: codingPath + [key],
        debugDescription: "Value was nil but property is non-optional"
      )
      let error = DecodingError.valueNotFound([Any].self, context)
      let decoder = try superDecoder(forKey: key)
      decoder.reportError(error)
      return PolymorphicLossyArrayValue(
        wrappedValue: [],
        outcome: .recoveredFrom(error, wasReported: true),
        results: []
      )
      #else
      return PolymorphicLossyArrayValue(wrappedValue: [], outcome: .valueWasNil)
      #endif
    }

    // Try to decode the array
    do {
      let decoder = try superDecoder(forKey: key)
      return try PolymorphicLossyArrayValue(from: decoder)
    } catch {
      // If decoding fails (e.g., not an array), return empty array
      #if DEBUG
      return PolymorphicLossyArrayValue(
        wrappedValue: [],
        outcome: .recoveredFrom(error, wasReported: false),
        results: []
      )
      #else
      return PolymorphicLossyArrayValue(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: false))
      #endif
    }
  }

  public func decodeIfPresent<T>(
    _: PolymorphicLossyArrayValue<T>.Type,
    forKey key: Self.Key
  ) throws -> PolymorphicLossyArrayValue<T>? where T: PolymorphicCodableStrategy {
    // Check if key exists
    guard contains(key) else {
      return nil
    }

    // Check if value is null
    if try decodeNil(forKey: key) {
      #if DEBUG
      let context = DecodingError.Context(
        codingPath: codingPath + [key],
        debugDescription: "Value was nil but property is non-optional"
      )
      let error = DecodingError.valueNotFound([Any].self, context)
      let decoder = try superDecoder(forKey: key)
      decoder.reportError(error)
      return PolymorphicLossyArrayValue(
        wrappedValue: [],
        outcome: .recoveredFrom(error, wasReported: true),
        results: []
      )
      #else
      return PolymorphicLossyArrayValue(wrappedValue: [])
      #endif
    }

    // Try to decode using PolymorphicLossyArrayValue's decoder
    let decoder = try superDecoder(forKey: key)
    return try PolymorphicLossyArrayValue(from: decoder)
  }
}
