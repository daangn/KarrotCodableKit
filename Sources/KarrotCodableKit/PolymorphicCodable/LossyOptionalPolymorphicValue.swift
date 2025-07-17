//
//  LossyOptionalPolymorphicValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "LossyOptionalPolymorphicValue")
public typealias DefaultNilPolymorphicValue<PolymorphicType: PolymorphicCodableStrategy> =
  LossyOptionalPolymorphicValue<PolymorphicType>

/// A property wrapper for decoding an optional polymorphic object, providing `nil` as a default value upon decoding failure.
///
/// This wrapper attempts to decode a single polymorphic value using the provided `PolymorphicType` strategy.
/// Unlike `@PolymorphicValue`, if the `PolymorphicType.decode(from:)` method throws *any* error during decoding
/// (e.g., missing identifier key, unknown identifier value, invalid data for the concrete type, or even a missing key for the value itself),
/// this wrapper catches the error and assigns `nil` to the `wrappedValue`.
/// It logs the encountered error using `print`.
///
/// Encoding behavior:
/// - If `wrappedValue` is `nil`, it encodes nothing (or `null` if used in an unkeyed container context where nulls are explicit).
/// - If `wrappedValue` holds a value, it delegates encoding to the `PolymorphicType` strategy, similar to `@PolymorphicValue`.
///
@propertyWrapper
public struct LossyOptionalPolymorphicValue<PolymorphicType: PolymorphicCodableStrategy> {
  /// The decoded optional value of the expected polymorphic type. Defaults to `nil` on decoding failure.
  public var wrappedValue: PolymorphicType.ExpectedType?

  public init(wrappedValue: PolymorphicType.ExpectedType?) {
    self.wrappedValue = wrappedValue
  }
}

extension LossyOptionalPolymorphicValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    try encoder.encodeIfPresent(
      wrappedValue,
      codingKey: PolymorphicType.polymorphicMetaCodingKey
    )
  }
}

extension LossyOptionalPolymorphicValue: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      wrappedValue = try PolymorphicType.decode(from: decoder)
    } catch {
      print("`LossyOptionalPolymorphicValue` decode catch error: \(error)")
      self.wrappedValue = nil
    }
  }
}

extension LossyOptionalPolymorphicValue: Equatable where PolymorphicType.ExpectedType: Equatable {}
extension LossyOptionalPolymorphicValue: Hashable where PolymorphicType.ExpectedType: Hashable {}
extension LossyOptionalPolymorphicValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
