//
//  KeyedDecodingContainer+OptionalPolymorphicArrayValue.swift
//  KarrotCodableKit
//
//  Created by elon on 7/28/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
  public func decode<T>(
    _ type: OptionalPolymorphicArrayValue<T>.Type,
    forKey key: Key
  ) throws -> OptionalPolymorphicArrayValue<T> where T: PolymorphicCodableStrategy {
    try decodeIfPresent(type, forKey: key) ?? OptionalPolymorphicArrayValue(wrappedValue: nil)
  }

  public func decodeIfPresent<T>(
    _ type: OptionalPolymorphicArrayValue<T>.Type,
    forKey key: Self.Key
  ) throws -> OptionalPolymorphicArrayValue<T>? where T: PolymorphicCodableStrategy {
    // Check if the key exists
    guard contains(key) else {
      return OptionalPolymorphicArrayValue(wrappedValue: nil)
    }
    
    // Check if the value is null
    if try decodeNil(forKey: key) {
      return OptionalPolymorphicArrayValue(wrappedValue: nil)
    }
    
    // Decode the array
    var container = try nestedUnkeyedContainer(forKey: key)
    var elements = [T.ExpectedType]()
    
    while !container.isAtEnd {
      // Use PolymorphicValue for decoding each element
      let value = try container.decode(PolymorphicValue<T>.self)
      elements.append(value.wrappedValue)
    }
    
    return OptionalPolymorphicArrayValue(wrappedValue: elements)
  }
}