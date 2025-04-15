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

  /// Initializes the property wrapper with a pre-decoded value.
  public init(wrappedValue: PolymorphicType.ExpectedType) {
    self.wrappedValue = wrappedValue
  }
}

extension PolymorphicValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    try encoder.encode(wrappedValue, codingKey: PolymorphicType.polymorphicMetaCodingKey)
  }
}

extension PolymorphicValue: Decodable {
  public init(from decoder: Decoder) throws {
    self.wrappedValue = try PolymorphicType.decode(from: decoder)
  }
}

extension PolymorphicValue: Equatable where PolymorphicType.ExpectedType: Equatable {}
extension PolymorphicValue: Hashable where PolymorphicType.ExpectedType: Hashable {}
extension PolymorphicValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
