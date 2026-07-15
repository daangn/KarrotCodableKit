//
//  PolymorphicLossyArrayValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/18/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

@available(*, deprecated, renamed: "PolymorphicLossyArrayValue")
public typealias DefaultEmptyPolymorphicLossyArrayValue<PolymorphicType: PolymorphicCodableStrategy> =
  PolymorphicLossyArrayValue<PolymorphicType>

/// A property wrapper that decodes an array of polymorphic objects with lossy behavior for individual
/// elements, and defaults to an empty array `[]` if the array key is missing, the value is `null`,
/// or not a valid JSON array.
///
/// Decoding Behavior:
/// - Attempts to decode an unkeyed container (JSON array).
/// - If the container is successfully obtained, it iterates through the elements:
///   - For each element, it attempts to decode using `PolymorphicValue<PolymorphicType>`.
///   - If an element's decoding succeeds, the resulting value is kept.
///   - If an element's decoding fails (due to any error caught by the `PolymorphicType` strategy or
///     `PolymorphicValue`), the error is caught and the element is **skipped**. The failure is recorded
///     in the decoding `outcome` as an `ArrayDecodingError` and, in DEBUG builds, reported to the
///     resilient decoding error reporter — matching `@LossyArray` in BetterCodable.
/// - After iterating, `wrappedValue` contains an array of only the successfully decoded elements.
/// - If the value is `null` or not a valid JSON array, the error is recovered inside `init(from:)` and
///   `wrappedValue` is set to `[]`, so the recovery also applies when the wrapper is decoded directly
///   (e.g., nested in other collections). A missing key is handled by the `KeyedDecodingContainer`
///   overloads and likewise yields `[]`.
///
/// Encoding Behavior:
/// - Encodes the `wrappedValue` array. Each valid element is wrapped using
///   `PolymorphicValue<PolymorphicType>` before being added to the encoded array.
///
/// This wrapper is ideal for handling arrays where some elements might be malformed, represent unknown
/// types, or are otherwise invalid, allowing the application to process the remaining valid elements
/// without failure.
///
/// **Important:** When decoding, invalid or malformed elements in the JSON array are simply omitted from
/// the resulting array rather than causing the entire decoding process to fail. This allows you to
/// successfully process JSON arrays even when they contain elements that don't conform to your expected
/// structure or type.
///
@propertyWrapper
public struct PolymorphicLossyArrayValue<PolymorphicType: PolymorphicCodableStrategy> {
  /// The decoded array containing only the successfully decoded polymorphic elements.
  /// Defaults to an empty array `[]` if the array key is missing or the value is not an array.
  public var wrappedValue: [PolymorphicType.ExpectedType]

  /// Tracks the outcome of the decoding process for resilient decoding
  public let outcome: ResilientDecodingOutcome

  #if DEBUG
  /// Results of decoding each element in the array (DEBUG only)
  let results: [Result<PolymorphicType.ExpectedType, Error>]
  #endif

  public init(wrappedValue: [PolymorphicType.ExpectedType]) {
    self.wrappedValue = wrappedValue
    outcome = .decodedSuccessfully
    #if DEBUG
    results = []
    #endif
  }

  #if DEBUG
  init(
    wrappedValue: [PolymorphicType.ExpectedType],
    outcome: ResilientDecodingOutcome,
    results: [Result<PolymorphicType.ExpectedType, Error>] = [],
  ) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
    self.results = results
  }
  #else
  init(wrappedValue: [PolymorphicType.ExpectedType], outcome: ResilientDecodingOutcome) {
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

extension PolymorphicLossyArrayValue: Decodable {
  public init(from decoder: Decoder) throws {
    // Check for null first
    if let singleValueContainer = try? decoder.singleValueContainer(), singleValueContainer.decodeNil() {
      #if DEBUG
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Value was nil but property is non-optional",
      )
      let error = DecodingError.valueNotFound([PolymorphicType.ExpectedType].self, context)
      decoder.reportError(error)
      self.init(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: true), results: [])
      #else
      self.init(wrappedValue: [], outcome: .valueWasNil)
      #endif
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
      self.init(wrappedValue: decoded.elements)
      #endif
    } catch {
      // An invalid array-level value (e.g., not an array) recovers to an empty array.
      #if DEBUG
      decoder.reportError(error)
      self.init(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: true), results: [])
      #else
      self.init(wrappedValue: [], outcome: .recoveredFrom(error, wasReported: false))
      #endif
    }
  }

}

extension PolymorphicLossyArrayValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    let polymorphicValues = wrappedValue.map {
      PolymorphicValue<PolymorphicType>(wrappedValue: $0)
    }
    try polymorphicValues.encode(to: encoder)
  }
}

extension PolymorphicLossyArrayValue: Equatable where PolymorphicType.ExpectedType: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension PolymorphicLossyArrayValue: Hashable where PolymorphicType.ExpectedType: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension PolymorphicLossyArrayValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
