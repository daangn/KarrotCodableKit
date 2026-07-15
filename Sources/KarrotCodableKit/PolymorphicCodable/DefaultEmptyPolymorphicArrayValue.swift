//
//  DefaultEmptyPolymorphicArrayValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A property wrapper that decodes an array of polymorphic objects, providing an empty array `[]` as a default
/// if the array key is missing, the value is `null`, or the value is not a valid JSON array.
///
/// Decoding Behavior:
/// - It attempts to decode an unkeyed container (JSON array).
/// - If the container is successfully obtained, it decodes each element using `PolymorphicValue<PolymorphicType>`.
/// - **Crucially, if *any* element within the array fails to decode according to the `PolymorphicType` strategy,
///   the error is caught and the *entire* array falls back to an empty array `[]`.** This wrapper does **not**
///   skip individual invalid elements while keeping the valid ones.
/// - If obtaining the unkeyed container fails (e.g., the key is missing, the value is `null`, or the value is
///   not an array), it likewise catches the error and assigns `[]` to `wrappedValue`.
/// - Every recovered error is recorded as a `.recoveredFrom` outcome and, in DEBUG builds, reported to the
///   resilient decoding error reporter.
///
/// Encoding Behavior:
/// - Encodes the `wrappedValue` array. Each element is wrapped using `PolymorphicValue<PolymorphicType>`
///   before being added to the encoded array.
///
/// Use this wrapper when you expect an array that should either be entirely valid (according to the strategy)
/// or absent/null — any failure yields an empty array rather than a decoding error.
/// If you need to gracefully handle individual invalid elements within the array,
/// use `@PolymorphicLossyArrayValue` instead.
///
/// **Note:** If you need to decode JSON arrays that may contain some invalid elements and want to ignore just
/// those elements while keeping the valid ones, use `@PolymorphicLossyArrayValue` instead of this wrapper.
///
@propertyWrapper
public struct DefaultEmptyPolymorphicArrayValue<PolymorphicType: PolymorphicCodableStrategy> {
  /// The decoded array of values. Defaults to an empty array `[]` if the array key is missing
  /// or decoding fails at the array level.
  public var wrappedValue: [PolymorphicType.ExpectedType]

  /// Tracks the outcome of the decoding process for resilient decoding
  public let outcome: ResilientDecodingOutcome

  public init(wrappedValue: [PolymorphicType.ExpectedType]) {
    self.wrappedValue = wrappedValue
    outcome = .decodedSuccessfully
  }

  init(wrappedValue: [PolymorphicType.ExpectedType], outcome: ResilientDecodingOutcome) {
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

extension DefaultEmptyPolymorphicArrayValue: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      var container = try decoder.unkeyedContainer()
      var elements = [PolymorphicType.ExpectedType]()

      while !container.isAtEnd {
        let value = try container.decode(PolymorphicValue<PolymorphicType>.self).wrappedValue
        elements.append(value)
      }

      wrappedValue = elements
      outcome = .decodedSuccessfully
    } catch {
      // Report error to error reporter
      #if DEBUG
      decoder.reportError(error)
      wrappedValue = []
      outcome = .recoveredFrom(error, wasReported: true)
      #else
      wrappedValue = []
      outcome = .recoveredFrom(error, wasReported: false)
      #endif
    }
  }
}

extension DefaultEmptyPolymorphicArrayValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    let polymorphicValues = wrappedValue.map {
      PolymorphicValue<PolymorphicType>(wrappedValue: $0)
    }
    try polymorphicValues.encode(to: encoder)
  }
}

extension DefaultEmptyPolymorphicArrayValue: Equatable where PolymorphicType.ExpectedType: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension DefaultEmptyPolymorphicArrayValue: Hashable where PolymorphicType.ExpectedType: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension DefaultEmptyPolymorphicArrayValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
