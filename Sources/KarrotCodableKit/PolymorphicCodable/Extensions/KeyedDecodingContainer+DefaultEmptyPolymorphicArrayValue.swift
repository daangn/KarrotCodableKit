//
//  KeyedDecodingContainer+DefaultEmptyPolymorphicArrayValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
  public func decode<T>(
    _: DefaultEmptyPolymorphicArrayValue<T>.Type,
    forKey key: Key
  ) throws -> DefaultEmptyPolymorphicArrayValue<T> where T: PolymorphicCodableStrategy {
    // Check if key exists
    guard contains(key) else {
      #if DEBUG
      let context = DecodingError.Context(
        codingPath: codingPath + [key],
        debugDescription: "Key not found but property is non-optional"
      )
      let error = DecodingError.keyNotFound(key, context)
      let decoder = try superDecoder(forKey: key)
      decoder.reportError(error)
      return DefaultEmptyPolymorphicArrayValue(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: true))
      #else
      return DefaultEmptyPolymorphicArrayValue(wrappedValue: [], outcome: .keyNotFound)
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
      return DefaultEmptyPolymorphicArrayValue(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: true))
      #else
      return DefaultEmptyPolymorphicArrayValue(wrappedValue: [], outcome: .valueWasNil)
      #endif
    }

    // Try to decode using the property wrapper's decoder
    let decoder = try superDecoder(forKey: key)
    return try DefaultEmptyPolymorphicArrayValue(from: decoder)
  }

  public func decodeIfPresent<T>(
    _: DefaultEmptyPolymorphicArrayValue<T>.Type,
    forKey key: Self.Key
  ) throws -> DefaultEmptyPolymorphicArrayValue<T>? where T: PolymorphicCodableStrategy {
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
      return DefaultEmptyPolymorphicArrayValue(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: true))
      #else
      return DefaultEmptyPolymorphicArrayValue(wrappedValue: [], outcome: .valueWasNil)
      #endif
    }

    // Try to decode using the property wrapper's decoder
    let decoder = try superDecoder(forKey: key)
    return try DefaultEmptyPolymorphicArrayValue(from: decoder)
  }
}
