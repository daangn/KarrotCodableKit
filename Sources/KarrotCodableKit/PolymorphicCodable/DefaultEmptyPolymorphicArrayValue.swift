//
//  DefaultEmptyPolymorphicArrayValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A property wrapper that decodes an array of polymorphic objects, providing an empty array `[]` as a default
/// if the array key is missing, the value is `null`, or the value is not a valid JSON array.
///
/// Decoding Behavior:
/// - It attempts to decode an unkeyed container (JSON array).
/// - If the container is successfully obtained, it decodes each element using `PolymorphicValue<PolymorphicType>`.
/// - **Crucially, if *any* element within the array fails to decode according to the `PolymorphicType` strategy, the entire decoding process for the wrapper fails, and an error is thrown.** This wrapper does **not** skip invalid elements.
/// - If the initial step of obtaining the unkeyed container fails (e.g., the key is missing in the parent JSON object, or the corresponding value is `null` or not an array), it catches the error, assigns `[]` to `wrappedValue`, and logs the error using `print`.
///
/// Encoding Behavior:
/// - Encodes the `wrappedValue` array. Each element is wrapped using `PolymorphicValue<PolymorphicType>` before being added to the encoded array.
///
/// Use this wrapper when you expect an array that should either be present and entirely valid (according to the strategy) or completely absent/null, in which case an empty array is acceptable.
/// If you need to gracefully handle individual invalid elements within the array, use `@PolymorphicLossyArrayValue` instead.
///
/// **Note:** If you need to decode JSON arrays that may contain some invalid elements and want to ignore just those elements
/// while keeping the valid ones, use `@PolymorphicLossyArrayValue` instead of this wrapper.
///
@propertyWrapper
public struct DefaultEmptyPolymorphicArrayValue<PolymorphicType: PolymorphicCodableStrategy> {
  /// The decoded array of values. Defaults to an empty array `[]` if the array key is missing or decoding fails at the array level.
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

      self.wrappedValue = elements
    } catch {
      print("`DefaultEmptyPolymorphicArrayValue` decode catch error: \(error)")
      self.wrappedValue = []
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
