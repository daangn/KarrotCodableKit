//
//  PolymorphicArrayValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

@propertyWrapper
public struct PolymorphicArrayValue<PolymorphicType: PolymorphicCodableStrategy> {
  public var wrappedValue: [PolymorphicType.ExpectedType]

  public init(wrappedValue: [PolymorphicType.ExpectedType]) {
    self.wrappedValue = wrappedValue
  }
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

extension PolymorphicArrayValue: Equatable where PolymorphicType.ExpectedType: Equatable {}
extension PolymorphicArrayValue: Hashable where PolymorphicType.ExpectedType: Hashable {}
extension PolymorphicArrayValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
