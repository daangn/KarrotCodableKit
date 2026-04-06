//
//  KeyedDecodingContainer+OptionalPolymorphicLossyArrayValue.swift
//  KarrotCodableKit
//
//  Created by KYHyeon on 4/6/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
  public func decode<T>(
    _ type: OptionalPolymorphicLossyArrayValue<T>.Type,
    forKey key: Key
  ) throws -> OptionalPolymorphicLossyArrayValue<T> where T: PolymorphicCodableStrategy {
    if let value = try decodeIfPresent(type, forKey: key) {
      return value
    } else {
      return OptionalPolymorphicLossyArrayValue(wrappedValue: nil, outcome: .keyNotFound)
    }
  }

  public func decodeIfPresent<T>(
    _ type: OptionalPolymorphicLossyArrayValue<T>.Type,
    forKey key: Self.Key
  ) throws -> OptionalPolymorphicLossyArrayValue<T>? where T: PolymorphicCodableStrategy {
    // Check if key exists
    guard contains(key) else {
      return nil
    }

    // Check if value is null
    if try decodeNil(forKey: key) {
      return OptionalPolymorphicLossyArrayValue(wrappedValue: nil, outcome: .valueWasNil)
    }

    // Try to decode the array with lossy behavior
    let decoder = try superDecoder(forKey: key)
    return try OptionalPolymorphicLossyArrayValue(from: decoder)
  }
}
