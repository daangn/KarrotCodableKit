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
    try decodeIfPresent(type, forKey: key) ?? LossyOptionalPolymorphicValue(wrappedValue: nil)
  }

  public func decodeIfPresent<T>(
    _ type: LossyOptionalPolymorphicValue<T>.Type,
    forKey key: Self.Key
  ) throws -> LossyOptionalPolymorphicValue<T> where T.ExpectedType: Decodable {
    let optionalValue = try decodeIfPresent(T.ExpectedType.self, forKey: key)
    return LossyOptionalPolymorphicValue(wrappedValue: optionalValue)
  }
}
