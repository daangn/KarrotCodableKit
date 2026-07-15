//
//  KeyedEncodingContainer+OmitNilPolymorphicEncodable.swift
//  KarrotCodableKit
//
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// An optional polymorphic property wrapper whose key should be omitted when its value is `nil`.
public protocol OmitNilPolymorphicEncodable: Encodable {
  /// `true` when the wrapped optional value is `nil`.
  var isWrappedValueNil: Bool { get }
}

extension KeyedEncodingContainer {
  /// Encodes an omit-nil polymorphic wrapper, skipping the key entirely when its value is `nil`.
  ///
  /// This mirrors Apple's default `Codable` behavior for optional properties, where a `nil` value
  /// results in the key being skipped rather than encoded as an explicit `null`. It is the encoding-side
  /// counterpart to the `decode(_:forKey:)` overload that treats a missing key as `nil`.
  ///
  /// This overload is chosen by overload resolution over the generic `encode<T: Encodable>` because
  /// its `OmitNilPolymorphicEncodable` constraint is more specific.
  public mutating func encode<Wrapper>(
    _ value: Wrapper,
    forKey key: Key
  ) throws where Wrapper: OmitNilPolymorphicEncodable {
    guard !value.isWrappedValueNil else { return }
    try value.encode(to: superEncoder(forKey: key))
  }
}

extension OptionalPolymorphicValue: OmitNilPolymorphicEncodable {
  public var isWrappedValueNil: Bool { wrappedValue == nil }
}

extension LossyOptionalPolymorphicValue: OmitNilPolymorphicEncodable {
  public var isWrappedValueNil: Bool { wrappedValue == nil }
}

extension OptionalPolymorphicArrayValue: OmitNilPolymorphicEncodable {
  public var isWrappedValueNil: Bool { wrappedValue == nil }
}

extension OptionalPolymorphicLossyArrayValue: OmitNilPolymorphicEncodable {
  public var isWrappedValueNil: Bool { wrappedValue == nil }
}
