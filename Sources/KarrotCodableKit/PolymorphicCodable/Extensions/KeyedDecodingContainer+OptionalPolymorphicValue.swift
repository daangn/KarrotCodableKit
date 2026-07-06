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
    switch try polymorphicKeyPresence(forKey: key) {
    case .missing:
      return nil

    case .null:
      return OptionalPolymorphicValue(wrappedValue: nil, outcome: .valueWasNil)

    case .present:
      // OptionalPolymorphicValue throws errors instead of recovering
      let value = try T.decode(from: superDecoder(forKey: key))
      return OptionalPolymorphicValue(wrappedValue: value, outcome: .decodedSuccessfully)
    }
  }
}
