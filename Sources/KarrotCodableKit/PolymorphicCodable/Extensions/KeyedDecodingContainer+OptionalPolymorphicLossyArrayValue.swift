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
    forKey key: Key,
  ) throws -> OptionalPolymorphicLossyArrayValue<T> where T: PolymorphicCodableStrategy {
    if let value = try decodeIfPresent(type, forKey: key) {
      value
    } else {
      OptionalPolymorphicLossyArrayValue(wrappedValue: nil, outcome: .keyNotFound)
    }
  }

  public func decodeIfPresent<T>(
    _ type: OptionalPolymorphicLossyArrayValue<T>.Type,
    forKey key: Self.Key,
  ) throws -> OptionalPolymorphicLossyArrayValue<T>? where T: PolymorphicCodableStrategy {
    // Check if key exists
    guard contains(key) else {
      return nil
    }

    // Null, non-array values, and element failures are all handled inside `init(from:)`.
    return try OptionalPolymorphicLossyArrayValue(from: superDecoder(forKey: key))
  }
}
