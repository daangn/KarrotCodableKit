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
    try decodeIfPresent(type, forKey: key) ?? DefaultEmptyPolymorphicArrayValue(wrappedValue: [])
  }

  public func decodeIfPresent<T>(
    _ type: DefaultEmptyPolymorphicArrayValue<T>.Type,
    forKey key: Self.Key
  ) throws -> DefaultEmptyPolymorphicArrayValue<T> where T.ExpectedType: Decodable {
    let optionalArrayValue = try decodeIfPresent([T.ExpectedType].self, forKey: key)
    return DefaultEmptyPolymorphicArrayValue(wrappedValue: optionalArrayValue ?? [])
  }
}
