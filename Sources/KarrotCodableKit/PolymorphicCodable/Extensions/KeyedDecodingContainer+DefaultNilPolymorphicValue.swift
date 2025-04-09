//
//  KeyedDecodingContainer+DefaultNilPolymorphicValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
  public func decode<T>(
    _ type: DefaultNilPolymorphicValue<T>.Type,
    forKey key: Key
  ) throws -> DefaultNilPolymorphicValue<T> where T: PolymorphicCodableStrategy {
    try decodeIfPresent(type, forKey: key) ?? DefaultNilPolymorphicValue(wrappedValue: nil)
  }

  public func decodeIfPresent<T>(
    _ type: DefaultNilPolymorphicValue<T>.Type,
    forKey key: Self.Key
  ) throws -> DefaultNilPolymorphicValue<T> where T.ExpectedType: Decodable {
    let optionalValue = try decodeIfPresent(T.ExpectedType.self, forKey: key)
    return DefaultNilPolymorphicValue(wrappedValue: optionalValue)
  }
}
