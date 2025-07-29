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
    if let value = try decodeIfPresent(type, forKey: key) {
      return value
    } else {
      #if DEBUG
      return OptionalPolymorphicArrayValue(wrappedValue: nil, outcome: .keyNotFound)
      #else
      return OptionalPolymorphicArrayValue(wrappedValue: nil)
      #endif
    }
  }

  public func decodeIfPresent<T>(
    _ type: OptionalPolymorphicArrayValue<T>.Type,
    forKey key: Self.Key
  ) throws -> OptionalPolymorphicArrayValue<T>? where T: PolymorphicCodableStrategy {
    // Check if the key exists
    guard contains(key) else {
      return nil
    }
    
    // Check if the value is null
    if try decodeNil(forKey: key) {
      #if DEBUG
      return OptionalPolymorphicArrayValue(wrappedValue: nil, outcome: .valueWasNil)
      #else
      return OptionalPolymorphicArrayValue(wrappedValue: nil)
      #endif
    }
    
    // Try to decode the array
    do {
      var container = try nestedUnkeyedContainer(forKey: key)
      var elements = [T.ExpectedType]()
      
      while !container.isAtEnd {
        // Use PolymorphicValue for decoding each element
        let value = try container.decode(PolymorphicValue<T>.self)
        elements.append(value.wrappedValue)
      }
      
      #if DEBUG
      return OptionalPolymorphicArrayValue(wrappedValue: elements, outcome: .decodedSuccessfully)
      #else
      return OptionalPolymorphicArrayValue(wrappedValue: elements)
      #endif
    } catch {
      // Report the error through superDecoder
      let decoder = try superDecoder(forKey: key)
      decoder.reportError(error)
      throw error
    }
  }
}