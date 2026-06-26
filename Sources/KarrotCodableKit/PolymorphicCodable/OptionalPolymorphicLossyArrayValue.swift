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
/// This wrapper combines the optionality handling of ``OptionalPolymorphicArrayValue`` with
/// the lossy element decoding of ``PolymorphicLossyArrayValue``.
///
/// Key behaviors:
/// - The array itself is optional (`[Element]?`), returning `nil` when the key is missing or the value is `null`
/// - Invalid elements within a present array are silently skipped rather than causing decoding failure
///
/// Comparison with similar wrappers:
/// - ``PolymorphicLossyArrayValue``: For required arrays that default to `[]` when missing or null
/// - ``OptionalPolymorphicArrayValue``: For optional arrays that throw on invalid elements
/// - ``DefaultEmptyPolymorphicArrayValue``: For required arrays that default to `[]` when missing or null,
///   strict on elements
///
/// Decoding behavior:
/// - If the key is missing or the value is `null`, `wrappedValue` is set to `nil`
/// - If the value is a valid array, each element is decoded using `PolymorphicValue<PolymorphicType>`
/// - If an element fails to decode, the error is caught and the element is **skipped**
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
    results: [Result<PolymorphicType.ExpectedType, Error>] = []
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
  private struct AnyDecodableValue: Decodable {}

  public init(from decoder: Decoder) throws {
    // First check if the value is nil
    let singleValueContainer = try decoder.singleValueContainer()
    if singleValueContainer.decodeNil() {
      self.init(wrappedValue: nil, outcome: .valueWasNil)
      return
    }

    // Decode as an array with lossy behavior
    var container = try decoder.unkeyedContainer()

    var elements = [PolymorphicType.ExpectedType]()
    #if DEBUG
    var results = [Result<PolymorphicType.ExpectedType, Error>]()
    #endif

    while !container.isAtEnd {
      do {
        let value = try container.decode(PolymorphicValue<PolymorphicType>.self).wrappedValue
        elements.append(value)
        #if DEBUG
        results.append(.success(value))
        #endif
      } catch {
        // Decoding processing to prevent infinite loops if decoding fails.
        _ = try? container.decode(AnyDecodableValue.self)
        #if DEBUG
        results.append(.failure(error))
        #endif
      }
    }

    #if DEBUG
    self.init(wrappedValue: elements, outcome: .decodedSuccessfully, results: results)
    #else
    self.init(wrappedValue: elements, outcome: .decodedSuccessfully)
    #endif
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
