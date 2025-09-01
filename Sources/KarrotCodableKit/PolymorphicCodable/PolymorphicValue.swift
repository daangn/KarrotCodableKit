//
//  PolymorphicValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A property wrapper that delegates the encoding and decoding of a single polymorphic object
/// to a specified `PolymorphicCodableStrategy`.
///
/// When decoding, this wrapper relies on the `PolymorphicType.decode(from:)` method.
/// The strategy is responsible for identifying the concrete type (usually based on a type identifier field)
/// and decoding the corresponding object. If the strategy cannot determine the type or encounters
/// a decoding error for the identified type, it will throw an error.
///
/// When encoding, it uses the `PolymorphicType.polymorphicMetaCodingKey` defined by the strategy
/// to potentially wrap the encoded object within a nested structure if required by the strategy.
///
@propertyWrapper
public struct PolymorphicValue<PolymorphicType: PolymorphicCodableStrategy> {
  /// The decoded value of the expected polymorphic type.
  public var wrappedValue: PolymorphicType.ExpectedType

  public let outcome: ResilientDecodingOutcome

  /// Initializes the property wrapper with a pre-decoded value.
  public init(wrappedValue: PolymorphicType.ExpectedType) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
  }

  init(wrappedValue: PolymorphicType.ExpectedType, outcome: ResilientDecodingOutcome) {
    self.wrappedValue = wrappedValue
    self.outcome = outcome
  }

  #if DEBUG
  public var projectedValue: PolymorphicProjectedValue {
    PolymorphicProjectedValue(outcome: outcome)
  }
  #endif
}

extension PolymorphicValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    try encoder.encode(wrappedValue, codingKey: PolymorphicType.polymorphicMetaCodingKey)
  }
}

extension PolymorphicValue: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      self.wrappedValue = try PolymorphicType.decode(from: decoder)
      self.outcome = .decodedSuccessfully
    } catch {
      #if DEBUG
      decoder.reportError(error)
      #endif
      throw error
    }
  }
}

extension PolymorphicValue: Equatable where PolymorphicType.ExpectedType: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension PolymorphicValue: Hashable where PolymorphicType.ExpectedType: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension PolymorphicValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
