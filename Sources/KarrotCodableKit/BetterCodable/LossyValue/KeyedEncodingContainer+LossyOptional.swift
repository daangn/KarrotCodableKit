//
//  KeyedEncodingContainer+LossyOptional.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/26/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension KeyedEncodingContainer {
  /// Encodes a `@LossyOptional` value, omitting the key entirely when the wrapped value is `nil`.
  ///
  /// `LossyOptional` is a `DefaultCodable<DefaultNilStrategy>` alias, so this overload is constrained to
  /// `DefaultNilStrategy` to target only the optional case. Other `DefaultCodable` wrappers
  /// (`@DefaultFalse`, `@DefaultEmptyArray`, ...) keep encoding their non-optional default value.
  ///
  /// This mirrors Apple's default `Codable` behavior for optional properties, where a `nil` value
  /// results in the key being skipped rather than encoded as an explicit `null`. It is the encoding-side
  /// counterpart to the `decode(_:forKey:)` overload that treats a missing key as the default `nil`.
  public mutating func encode(
    _ value: DefaultCodable<DefaultNilStrategy<some Encodable>>,
    forKey key: Key,
  ) throws {
    guard value.wrappedValue != nil else { return }
    try value.encode(to: superEncoder(forKey: key))
  }
}
