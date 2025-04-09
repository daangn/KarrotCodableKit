//
//  PolymorphicCodableStrategy.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

public protocol PolymorphicCodableStrategy {
  associatedtype ExpectedType
  static var polymorphicMetaCodingKey: CodingKey { get }
  static func decode(from decoder: Decoder) throws -> ExpectedType
}

@propertyWrapper
public struct PolymorphicValue<PolymorphicType: PolymorphicCodableStrategy> {
  public var wrappedValue: PolymorphicType.ExpectedType

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
