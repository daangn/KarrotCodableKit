//
//  OptionalPolymorphicValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 7/16/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A property wrapper for decoding an optional polymorphic object that throws errors on decoding failure.
///
/// This wrapper attempts to decode a single polymorphic value using the provided `PolymorphicType` strategy.
/// Unlike `@LossyOptionalPolymorphicValue`, if the `PolymorphicType.decode(from:)` method throws *any* error during decoding
/// (e.g., missing identifier key, unknown identifier value, invalid data for the concrete type, or even a missing key for the value itself),
/// this wrapper **re-throws the error** instead of providing a default value.
///
/// **Note:** If you need error-tolerant decoding that assigns `nil` on failure, use `@LossyOptionalPolymorphicValue` instead.
///
/// Encoding behavior:
/// - If `wrappedValue` is `nil`, it encodes nothing (or `null` if used in an unkeyed container context where nulls are explicit).
/// - If `wrappedValue` holds a value, it delegates encoding to the `PolymorphicType` strategy, similar to `@PolymorphicValue`.
///
@propertyWrapper
public struct OptionalPolymorphicValue<PolymorphicType: PolymorphicCodableStrategy> {
  /// The decoded optional value of the expected polymorphic type.
  public var wrappedValue: PolymorphicType.ExpectedType?

  /// Tracks the outcome of the decoding process for resilient decoding
  public let outcome: ResilientDecodingOutcome

  public init(wrappedValue: PolymorphicType.ExpectedType?) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }

  init(wrappedValue: PolymorphicType.ExpectedType?, outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }

  #if DEBUG
  /// The projected value providing access to decoding outcome
  public var projectedValue: PolymorphicProjectedValue {
    PolymorphicProjectedValue(outcome: outcome)
  }
  #endif
}

extension OptionalPolymorphicValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    try encoder.encodeIfPresent(
      wrappedValue,
      codingKey: PolymorphicType.polymorphicMetaCodingKey
    )
  }
}

extension OptionalPolymorphicValue: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      self.wrappedValue = try PolymorphicType.decode(from: decoder)
      self.outcome = .decodedSuccessfully
    } catch {
      // OptionalPolymorphicValue throws errors instead of recovering
      throw error
    }
  }
}

extension OptionalPolymorphicValue: Equatable where PolymorphicType.ExpectedType: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension OptionalPolymorphicValue: Hashable where PolymorphicType.ExpectedType: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension OptionalPolymorphicValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
