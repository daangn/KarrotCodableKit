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
    try decodeIfPresent(type, forKey: key) ?? OptionalPolymorphicValue(wrappedValue: nil)
  }

  public func decodeIfPresent<T>(
    _ type: OptionalPolymorphicValue<T>.Type,
    forKey key: Self.Key
  ) throws -> OptionalPolymorphicValue<T> where T.ExpectedType: Decodable {
    let optionalValue = try decodeIfPresent(T.ExpectedType.self, forKey: key)
    return OptionalPolymorphicValue(wrappedValue: optionalValue)
  }
}
