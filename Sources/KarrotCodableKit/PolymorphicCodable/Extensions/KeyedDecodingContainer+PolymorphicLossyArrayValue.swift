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
    switch try polymorphicKeyPresence(forKey: key) {
    case .missing:
      // Return empty array if key is missing
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

    case .null:
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

    case .present:
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
  }

  public func decodeIfPresent<T>(
    _: PolymorphicLossyArrayValue<T>.Type,
    forKey key: Self.Key
  ) throws -> PolymorphicLossyArrayValue<T>? where T: PolymorphicCodableStrategy {
    switch try polymorphicKeyPresence(forKey: key) {
    case .missing:
      return nil

    case .null:
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
      // Match `decode(_:forKey:)`: a null value maps to `.valueWasNil`, not `.decodedSuccessfully`.
      return PolymorphicLossyArrayValue(wrappedValue: [], outcome: .valueWasNil)
      #endif

    case .present:
      // Try to decode using PolymorphicLossyArrayValue's decoder
      let decoder = try superDecoder(forKey: key)
      return try PolymorphicLossyArrayValue(from: decoder)
    }
  }
}
