//
//  KeyedEncodingContainer+OptionalPolymorphicArrayValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/26/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension KeyedEncodingContainer {
  /// Encodes an `OptionalPolymorphicArrayValue`, omitting the key entirely when the wrapped array is `nil`.
  ///
  /// This mirrors Apple's default `Codable` behavior for optional properties, where a `nil` value
  /// results in the key being skipped rather than encoded as an explicit `null`. It is the encoding-side
  /// counterpart to the `decode(_:forKey:)` overload that treats a missing key as `nil`.
  public mutating func encode<T>(
    _ value: OptionalPolymorphicArrayValue<T>,
    forKey key: Key
  ) throws where T: PolymorphicCodableStrategy {
    guard value.wrappedValue != nil else { return }
    try value.encode(to: superEncoder(forKey: key))
  }
}
