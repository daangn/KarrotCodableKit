//
//  OptionalPolymorphicLossyArrayValue.swift
//  KarrotCodableKit
//
//  Created by KYHyeon on 4/6/26.
//  Copyright © 2026 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A property wrapper that decodes an optional array of polymorphic objects with lossy behavior
/// for individual elements.
///
/// This is the optional variant of ``PolymorphicLossyArrayValue`` and follows the exact same
/// policy; the only difference is that a missing key or an explicit `null` is represented
/// as `nil` instead of `[]`.
///
/// Key behaviors:
/// - The array itself is optional (`[Element]?`), returning `nil` when the key is missing or the value is `null`
/// - Invalid elements within a present array are silently skipped rather than causing decoding failure
/// - A present value that is not a valid JSON array recovers to an empty array `[]` instead of
///   throwing; `nil` stays reserved for a missing key or an explicit `null`
///
/// Comparison with similar wrappers:
/// - ``PolymorphicLossyArrayValue``: For required arrays that default to `[]` when missing, null,
///   or not a valid JSON array
/// - ``OptionalPolymorphicArrayValue``: For optional arrays that throw on invalid elements
/// - ``DefaultEmptyPolymorphicArrayValue``: For required arrays that default to `[]` when missing or null,
///   and fall back to `[]` entirely when any element is invalid
///
/// Decoding behavior:
/// - If the key is missing or the value is `null`, `wrappedValue` is set to `nil`
/// - If the value is a valid array, each element is decoded using `PolymorphicValue<PolymorphicType>`
/// - If an element fails to decode, the error is caught and the element is **skipped**;
///   the failure is recorded in the decoding `outcome` as an `ArrayDecodingError`
/// - If the value is not a valid JSON array, the error is recovered and `wrappedValue` is set to `[]`
/// - Empty arrays are decoded as empty arrays, not `nil`
///
/// Encoding behavior:
/// - If `wrappedValue` is `nil`, the key is omitted (a `null` is only produced inside an unkeyed container)
/// - If `wrappedValue` contains an array, each element is encoded using the `PolymorphicType` strategy
///
@propertyWrapper
public struct OptionalPolymorphicLossyArrayValue<PolymorphicType: PolymorphicCodableStrategy> {
  /// The decoded optional array containing only the successfully decoded polymorphic elements.
  /// `nil` if the key is missing or the value is `null`.
  public var wrappedValue: [PolymorphicType.ExpectedType]?

  /// Tracks the outcome of the decoding process for resilient decoding
  public let outcome: ResilientDecodingOutcome

  #if DEBUG
  /// Results of decoding each element in the array (DEBUG only)
  let results: [Result<PolymorphicType.ExpectedType, Error>]
  #endif

  public init(wrappedValue: [PolymorphicType.ExpectedType]?) {
    self.wrappedValue = wrappedValue
    outcome = .decodedSuccessfully
    #if DEBUG
    results = []
    #endif
  }

  #if DEBUG
  init(
    wrappedValue: [PolymorphicType.ExpectedType]?,
    outcome: ResilientDecodingOutcome,
    results: [Result<PolymorphicType.ExpectedType, Error>] = [],
  ) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
    self.results = results
  }
  #else
  init(wrappedValue: [PolymorphicType.ExpectedType]?, outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }
  #endif

  #if DEBUG
  /// The projected value providing access to decoding outcome
  public var projectedValue: PolymorphicLossyArrayProjectedValue<PolymorphicType.ExpectedType> {
    PolymorphicLossyArrayProjectedValue(outcome: outcome, results: results)
  }
  #endif
}

extension OptionalPolymorphicLossyArrayValue: Decodable {
  public init(from decoder: Decoder) throws {
    // First check if the value is nil
    if let singleValueContainer = try? decoder.singleValueContainer(), singleValueContainer.decodeNil() {
      self.init(wrappedValue: nil, outcome: .valueWasNil)
      return
    }

    do {
      var container = try decoder.unkeyedContainer()
      let decoded = try container.decodeLossyPolymorphicElements(of: PolymorphicType.self)

      #if DEBUG
      if decoded.results.contains(where: \.isFailure) {
        let error = ResilientDecodingOutcome.ArrayDecodingError(results: decoded.results)
        self.init(
          wrappedValue: decoded.elements,
          outcome: .recoveredFrom(error, wasReported: false),
          results: decoded.results,
        )
      } else {
        self.init(wrappedValue: decoded.elements, outcome: .decodedSuccessfully, results: decoded.results)
      }
      #else
      self.init(wrappedValue: decoded.elements, outcome: .decodedSuccessfully)
      #endif
    } catch {
      // Same policy as `PolymorphicLossyArrayValue`: an invalid array-level value recovers to `[]`.
      // `nil` stays reserved for a missing key or an explicit `null`.
      #if DEBUG
      decoder.reportError(error)
      self.init(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: true), results: [])
      #else
      self.init(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: false))
      #endif
    }
  }
}

extension OptionalPolymorphicLossyArrayValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    if let array = wrappedValue {
      let polymorphicValues = array.map {
        PolymorphicValue<PolymorphicType>(wrappedValue: $0)
      }
      try polymorphicValues.encode(to: encoder)
    } else {
      var container = encoder.singleValueContainer()
      try container.encodeNil()
    }
  }
}

extension OptionalPolymorphicLossyArrayValue: Equatable where PolymorphicType.ExpectedType: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension OptionalPolymorphicLossyArrayValue: Hashable where PolymorphicType.ExpectedType: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension OptionalPolymorphicLossyArrayValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
