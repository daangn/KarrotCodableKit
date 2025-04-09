//
//  DefaultEmptyPolymorphicArrayValue.swift
//
//
//  Created by Elon on 10/18/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultEmptyPolymorphicArrayValue<PolymorphicType: PolymorphicCodableStrategy> {
  public var wrappedValue: [PolymorphicType.ExpectedType]

  public init(wrappedValue: [PolymorphicType.ExpectedType]) {
    self.wrappedValue = wrappedValue
  }
}

extension DefaultEmptyPolymorphicArrayValue: Decodable {
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()

    do {
      var elements = [PolymorphicType.ExpectedType]()
      while !container.isAtEnd {
        let value = try container.decode(PolymorphicValue<PolymorphicType>.self).wrappedValue
        elements.append(value)
      }

      wrappedValue = elements
    } catch {
      print("`DefaultEmptyPolymorphicArrayValue` decode catch error: \(error)")
      wrappedValue = []
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

extension DefaultEmptyPolymorphicArrayValue: Equatable where PolymorphicType.ExpectedType: Equatable {}
extension DefaultEmptyPolymorphicArrayValue: Hashable where PolymorphicType.ExpectedType: Hashable {}
extension DefaultEmptyPolymorphicArrayValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
