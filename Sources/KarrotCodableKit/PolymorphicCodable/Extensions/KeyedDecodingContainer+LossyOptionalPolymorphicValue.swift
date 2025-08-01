//
//  KeyedDecodingContainer+LossyOptionalPolymorphicValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
  public func decode<T>(
    _ type: LossyOptionalPolymorphicValue<T>.Type,
    forKey key: Key
  ) throws -> LossyOptionalPolymorphicValue<T> where T: PolymorphicCodableStrategy {
    if let value = try decodeIfPresent(type, forKey: key) {
      value
    } else {
      LossyOptionalPolymorphicValue(wrappedValue: nil, outcome: .keyNotFound)
    }
  }

  public func decodeIfPresent<T>(
    _ type: LossyOptionalPolymorphicValue<T>.Type,
    forKey key: Self.Key
  ) throws -> LossyOptionalPolymorphicValue<T>? where T: PolymorphicCodableStrategy {
    // Check if key exists
    guard contains(key) else {
      return nil
    }

    // Check if value is null
    if try decodeNil(forKey: key) {
      return LossyOptionalPolymorphicValue(wrappedValue: nil, outcome: .valueWasNil)
    }

    // Try to decode the polymorphic value
    do {
      let decoder = try superDecoder(forKey: key)
      let value = try T.decode(from: decoder)
      return LossyOptionalPolymorphicValue(wrappedValue: value, outcome: .decodedSuccessfully)
    } catch {
      // Report error to resilient decoding error reporter
      let decoder = try? superDecoder(forKey: key)
      decoder?.reportError(error)
      return LossyOptionalPolymorphicValue(wrappedValue: nil, outcome: .recoveredFrom(error, wasReported: true))
    }
  }
}
