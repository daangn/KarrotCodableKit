//
//  KeyedDecodingContainer+PolymorphicLossyArrayValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
  public func decode<T>(
    _ type: PolymorphicLossyArrayValue<T>.Type,
    forKey key: Key
  ) throws -> PolymorphicLossyArrayValue<T> where T: PolymorphicCodableStrategy {
    try decodeIfPresent(type, forKey: key) ?? PolymorphicLossyArrayValue(wrappedValue: [])
  }

  public func decodeIfPresent<T>(
    _ type: PolymorphicLossyArrayValue<T>.Type,
    forKey key: Self.Key
  ) throws -> PolymorphicLossyArrayValue<T> where T.ExpectedType: Decodable {
    let optionalAarryValue = try decodeIfPresent([T.ExpectedType].self, forKey: key)
    return PolymorphicLossyArrayValue(wrappedValue: optionalAarryValue ?? [])
  }
}
