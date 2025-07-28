//
//  OptionalPolymorphicArrayValue.swift
//  KarrotCodableKit
//
//  Created by elon on 7/28/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A property wrapper for decoding an optional array of polymorphic objects that throws errors on decoding failure.
///
/// This wrapper handles arrays that may be absent (nil) while ensuring all present elements are valid according to
/// the polymorphic strategy. It differs from other array wrappers in how it handles optionality and errors.
///
/// Key behaviors:
/// - The array itself is optional (`[Element]?`), but elements within the array are non-optional
/// - Missing keys or null values result in `nil` without errors
/// - Invalid elements within an array cause the entire decoding to fail
///
/// Comparison with similar wrappers:
/// - `@PolymorphicArrayValue`: For required arrays that must be present
/// - `@DefaultEmptyPolymorphicArrayValue`: Returns empty array `[]` on any decoding failure
/// - `@PolymorphicLossyArrayValue`: Silently skips invalid elements within the array
///
/// Decoding behavior:
/// - If the key is missing or the value is `null`, `wrappedValue` is set to `nil`
/// - If the value is a valid array, each element is decoded using `PolymorphicValue<PolymorphicType>`
/// - If any element fails to decode, the entire decoding operation fails and the error is re-thrown
/// - Empty arrays are decoded as empty arrays, not `nil`
///
/// Encoding behavior:
/// - If `wrappedValue` is `nil`, encodes as `null`
/// - If `wrappedValue` contains an array, each element is encoded using the `PolymorphicType` strategy
///
@propertyWrapper
public struct OptionalPolymorphicArrayValue<PolymorphicType: PolymorphicCodableStrategy> {
  /// The decoded optional array of values conforming to the expected polymorphic type.
  public var wrappedValue: [PolymorphicType.ExpectedType]?

  /// Initializes the property wrapper with an optional array of values.
  public init(wrappedValue: [PolymorphicType.ExpectedType]?) {
    self.wrappedValue = wrappedValue
  }
}

extension OptionalPolymorphicArrayValue: Decodable {
  public init(from decoder: Decoder) throws {
    // Try to decode as an array container
    if let container = try? decoder.unkeyedContainer() {
      var mutableContainer = container
      var elements = [PolymorphicType.ExpectedType]()
      
      while !mutableContainer.isAtEnd {
        // Decode each element using PolymorphicValue
        // This ensures proper polymorphic decoding and error propagation
        let value = try mutableContainer.decode(PolymorphicValue<PolymorphicType>.self)
        elements.append(value.wrappedValue)
      }
      
      self.wrappedValue = elements
    } else {
      // If we can't get an unkeyed container, the value is either nil, missing, or not an array
      // Set wrappedValue to nil without throwing an error
      self.wrappedValue = nil
    }
  }
}

extension OptionalPolymorphicArrayValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    if let array = wrappedValue {
      // Wrap each element in PolymorphicValue for encoding
      let polymorphicValues = array.map {
        PolymorphicValue<PolymorphicType>(wrappedValue: $0)
      }
      try polymorphicValues.encode(to: encoder)
    } else {
      // Encode nil
      var container = encoder.singleValueContainer()
      try container.encodeNil()
    }
  }
}

extension OptionalPolymorphicArrayValue: Equatable where PolymorphicType.ExpectedType: Equatable {}
extension OptionalPolymorphicArrayValue: Hashable where PolymorphicType.ExpectedType: Hashable {}
extension OptionalPolymorphicArrayValue: Sendable where PolymorphicType.ExpectedType: Sendable {}