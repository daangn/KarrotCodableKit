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
    _ type: DefaultEmptyPolymorphicArrayValue<T>.Type,
    forKey key: Key
  ) throws -> DefaultEmptyPolymorphicArrayValue<T> where T: PolymorphicCodableStrategy {
    switch try polymorphicKeyPresence(forKey: key) {
    case .missing:
      return DefaultEmptyPolymorphicArrayValue(wrappedValue: [], outcome: .keyNotFound)

    case .null:
      return DefaultEmptyPolymorphicArrayValue(wrappedValue: [], outcome: .valueWasNil)

    case .present:
      // Try to decode using the property wrapper's decoder
      let decoder = try superDecoder(forKey: key)
      return try DefaultEmptyPolymorphicArrayValue(from: decoder)
    }
  }

  public func decodeIfPresent<T>(
    _ type: DefaultEmptyPolymorphicArrayValue<T>.Type,
    forKey key: Self.Key
  ) throws -> DefaultEmptyPolymorphicArrayValue<T>? where T: PolymorphicCodableStrategy {
    switch try polymorphicKeyPresence(forKey: key) {
    case .missing:
      return nil

    case .null:
      return DefaultEmptyPolymorphicArrayValue(wrappedValue: [], outcome: .valueWasNil)

    case .present:
      // Try to decode using the property wrapper's decoder
      let decoder = try superDecoder(forKey: key)
      return try DefaultEmptyPolymorphicArrayValue(from: decoder)
    }
  }
}
