//
//  KeyedDecodingContainer+OptionalPolymorphicValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/16/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
  public func decode<T>(
    _ type: OptionalPolymorphicValue<T>.Type,
    forKey key: Key
  ) throws -> OptionalPolymorphicValue<T> where T: PolymorphicCodableStrategy {
    if let value = try decodeIfPresent(type, forKey: key) {
      value
    } else {
      OptionalPolymorphicValue(wrappedValue: nil, outcome: .keyNotFound)
    }
  }

  public func decodeIfPresent<T>(
    _ type: OptionalPolymorphicValue<T>.Type,
    forKey key: Self.Key
  ) throws -> OptionalPolymorphicValue<T>? where T: PolymorphicCodableStrategy {
    // Check if key exists
    guard contains(key) else {
      return nil
    }

    // Check if value is null
    if try decodeNil(forKey: key) {
      return OptionalPolymorphicValue(wrappedValue: nil, outcome: .valueWasNil)
    }

    // Try to decode the polymorphic value
    do {
      let decoder = try superDecoder(forKey: key)
      let value = try T.decode(from: decoder)
      return OptionalPolymorphicValue(wrappedValue: value, outcome: .decodedSuccessfully)
    } catch {
      // OptionalPolymorphicValue throws errors instead of recovering
      throw error
    }
  }
}
