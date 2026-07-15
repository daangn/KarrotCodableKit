//
//  KeyedDecodingContainer+PolymorphicKeyPresence.swift
//  KarrotCodableKit
//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// Three-way result of probing a key before polymorphic decoding.
enum PolymorphicKeyPresence {
  /// The key is absent from the container.
  case missing
  /// The key is present but its value is JSON `null`.
  case null
  /// The key is present with a non-null value.
  case present
}

extension KeyedDecodingContainer {
  /// Resolves whether a key is missing, null, or present.
  ///
  /// Centralizes the `contains` / `decodeNil` ordering that every polymorphic property-wrapper
  /// decode overload previously duplicated. The caller acquires its own `superDecoder(forKey:)` or
  /// `nestedUnkeyedContainer(forKey:)` in the `.present` case, matching each wrapper's existing path.
  func polymorphicKeyPresence(forKey key: Key) throws -> PolymorphicKeyPresence {
    guard contains(key) else { return .missing }
    return try decodeNil(forKey: key) ? .null : .present
  }
}
