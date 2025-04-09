//
//  DefaultNilPolymorphicValue.swift
//
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

@propertyWrapper
public struct DefaultNilPolymorphicValue<PolymorphicType: PolymorphicCodableStrategy> {
  public var wrappedValue: PolymorphicType.ExpectedType?

  public init(wrappedValue: PolymorphicType.ExpectedType?) {
    self.wrappedValue = wrappedValue
  }
}

extension DefaultNilPolymorphicValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    try encoder.encodeIfPresent(
      wrappedValue,
      codingKey: PolymorphicType.polymorphicMetaCodingKey
    )
  }
}

extension DefaultNilPolymorphicValue: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      wrappedValue = try PolymorphicType.decode(from: decoder)
    } catch {
      print("`DefaultNilPolymorphicValue` decode catch error: \(error)")
      wrappedValue = nil
    }
  }
}

extension DefaultNilPolymorphicValue: Equatable where PolymorphicType.ExpectedType: Equatable {}
extension DefaultNilPolymorphicValue: Hashable where PolymorphicType.ExpectedType: Hashable {}
extension DefaultNilPolymorphicValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
