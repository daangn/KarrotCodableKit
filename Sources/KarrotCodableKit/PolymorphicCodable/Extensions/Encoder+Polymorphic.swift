//
//  Encoder+Polymorphic.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension Encoder {
  public func encode<ValueType, PolymorphicMetaCodingKey: CodingKey>(
    _ value: ValueType,
    codingKey: PolymorphicMetaCodingKey
  ) throws {
    guard let value = value as? PolymorphicEncodableType else {
      throw PolymorphicCodableError.unableToRepresentAsPolymorphicForEncoding("\(value)")
    }

    var container = container(keyedBy: PolymorphicMetaCodingKey.self)
    try container.encode(type(of: value).polymorphicIdentifier, forKey: codingKey)
    try value.encode(to: self)
  }

  public func encodeIfPresent<ValueType, PolymorphicMetaCodingKey: CodingKey>(
    _ value: ValueType?,
    codingKey: PolymorphicMetaCodingKey
  ) throws {
    guard let value else {
      var container = singleValueContainer()
      try container.encodeNil()
      return
    }

    guard let polymorphicValue = value as? PolymorphicEncodableType else {
      throw PolymorphicCodableError.unableToRepresentAsPolymorphicForEncoding("\(value)")
    }
    var container = container(keyedBy: PolymorphicMetaCodingKey.self)
    try container.encode(type(of: polymorphicValue).polymorphicIdentifier, forKey: codingKey)
    try polymorphicValue.encode(to: self)
  }
}
