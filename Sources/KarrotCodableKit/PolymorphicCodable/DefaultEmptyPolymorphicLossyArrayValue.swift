//
//  DefaultEmptyPolymorphicLossyArrayValue.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/18/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A property wrapper that decodes an array of polymorphic objects with lossy behavior for individual elements,
/// and defaults to an empty array `[]` if the array key is missing, the value is `null`, or not a valid JSON array.
///
/// Decoding Behavior:
/// - Attempts to decode an unkeyed container (JSON array).
/// - If the container is successfully obtained, it iterates through the elements:
///   - For each element, it attempts to decode using `PolymorphicValue<PolymorphicType>`.
///   - If an element's decoding succeeds, the resulting value is kept.
///   - If an element's decoding fails (due to any error caught by the `PolymorphicType` strategy or `PolymorphicValue`), the error is caught, logged using `print`, and the element is **skipped**.
///   - To prevent infinite loops on invalid data, it attempts to decode the failing element as `AnyDecodableValue` to advance the container's position.
/// - After iterating, `wrappedValue` contains an array of only the successfully decoded elements.
/// - If the initial step of obtaining the unkeyed container fails (e.g., missing key, `null` value, wrong type), it catches the error, assigns `[]` to `wrappedValue`, and logs the error.
///
/// Encoding Behavior:
/// - Encodes the `wrappedValue` array. Each valid element is wrapped using `PolymorphicValue<PolymorphicType>` before being added to the encoded array.
///
/// This wrapper is ideal for handling arrays where some elements might be malformed, represent unknown types,
/// or are otherwise invalid, allowing the application to process the remaining valid elements without failure.
///
/// **Important:** When decoding, invalid or malformed elements in the JSON array are simply omitted from the resulting array
/// rather than causing the entire decoding process to fail. This allows you to successfully process JSON arrays
/// even when they contain elements that don't conform to your expected structure or type.
///
@propertyWrapper
public struct DefaultEmptyPolymorphicLossyArrayValue<PolymorphicType: PolymorphicCodableStrategy> {
  /// The decoded array containing only the successfully decoded polymorphic elements. Defaults to an empty array `[]` if the array key is missing or the value is not an array.
  public var wrappedValue: [PolymorphicType.ExpectedType]

  public init(wrappedValue: [PolymorphicType.ExpectedType]) {
    self.wrappedValue = wrappedValue
  }
}

extension DefaultEmptyPolymorphicLossyArrayValue: Decodable {
  private struct AnyDecodableValue: Decodable {}

  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()

    var elements = [PolymorphicType.ExpectedType?]()
    while !container.isAtEnd {
      do {
        let value = try container.decode(PolymorphicValue<PolymorphicType>.self).wrappedValue
        elements.append(value)
      } catch {
        print("`DefaultEmptyPolymorphicLossyArrayValue` decode catch error: \(error)")

        // Decoding processing to prevent infinite loops if decoding fails.
        _ = try? container.decode(AnyDecodableValue.self)
      }
    }

    wrappedValue = elements.compactMap { $0 }
  }
}

extension DefaultEmptyPolymorphicLossyArrayValue: Encodable {
  public func encode(to encoder: Encoder) throws {
    let polymorphicValues = wrappedValue.map {
      PolymorphicValue<PolymorphicType>(wrappedValue: $0)
    }
    try polymorphicValues.encode(to: encoder)
  }
}

extension DefaultEmptyPolymorphicLossyArrayValue: Equatable where PolymorphicType.ExpectedType: Equatable {}
extension DefaultEmptyPolymorphicLossyArrayValue: Hashable where PolymorphicType.ExpectedType: Hashable {}
extension DefaultEmptyPolymorphicLossyArrayValue: Sendable where PolymorphicType.ExpectedType: Sendable {}
