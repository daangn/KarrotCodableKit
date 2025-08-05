//
//  PolymorphicArrayValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A property wrapper that decodes an array of polymorphic objects based on a specified strategy.
///
/// This wrapper iterates through a JSON array and attempts to decode each element
/// using `PolymorphicValue<PolymorphicType>`. It requires that each element in the array
/// conforms to the polymorphic structure defined by the `PolymorphicType` strategy.
/// If decoding any element fails according to the strategy's rules, the entire array decoding will fail.
///
@propertyWrapper
public struct PolymorphicArrayValue<PolymorphicType: PolymorphicCodableStrategy> {
  /// The decoded array of values, each conforming to the expected polymorphic type.
  public var wrappedValue: [PolymorphicType.ExpectedType]

  /// Tracks the outcome of the decoding process for resilient decoding
  public let outcome: ResilientDecodingOutcome

  /// Initializes the property wrapper with a pre-decoded array of values.
  public init(wrappedValue: [PolymorphicType.ExpectedType]) {
    self.wrappedValue = wrappedValue
    self.outcome = .decodedSuccessfully
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

extension PolymorphicArrayValue: Decodable {
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()

    var elements = [PolymorphicType.ExpectedType]()
    while !container.isAtEnd {
      let value = try container.decode(PolymorphicValue<PolymorphicType>.self).wrappedValue
      elements.append(value)
    }

    self.wrappedValue = elements
    self.outcome = .decodedSuccessfully
  }
}

extension PolymorphicArrayValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    let polymorphicValues = wrappedValue.map {
      PolymorphicValue<PolymorphicType>(wrappedValue: $0)
    }
    try polymorphicValues.encode(to: encoder)
  }
}

extension PolymorphicArrayValue: Equatable where PolymorphicType.ExpectedType: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension PolymorphicArrayValue: Hashable where PolymorphicType.ExpectedType: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension PolymorphicArrayValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
