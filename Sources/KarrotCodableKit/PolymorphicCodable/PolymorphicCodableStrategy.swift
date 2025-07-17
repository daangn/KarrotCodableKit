//
//  PolymorphicCodableStrategy.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/15/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A protocol that defines a strategy for polymorphic encoding and decoding of values.
///
/// Types conforming to this protocol provide the logic for decoding a polymorphic value from a `Decoder`,
/// typically by inspecting a type identifier field in the payload and dispatching to the appropriate concrete type.
///
/// This protocol is used by property wrappers such as `@PolymorphicValue`, `@PolymorphicArrayValue`,
/// `@LossyOptionalPolymorphicValue`, and others to delegate the actual decoding and encoding logic.
///
/// - `ExpectedType`: The type of value that will be produced by this strategy (e.g., a protocol or base class).
/// - `polymorphicMetaCodingKey`: The coding key used to locate the type identifier in the encoded data.
/// - `decode(from:)`: Decodes a value of the expected type from the given decoder, using the strategy's rules.
///
/// Example usage (without `@PolymorphicCodableStrategyProviding` macro):
/// ```swift
/// protocol ViewItem: Codable {
///   var id: String { get }
/// }
///
/// struct ViewItemCodableStrategy: PolymorphicCodableStrategy {
///   enum PolymorphicMetaCodingKey: CodingKey {
///     case type
///   }
///
///   static var polymorphicMetaCodingKey: CodingKey {
///     PolymorphicMetaCodingKey.type
///   }
///
///   static func decode(from decoder: Decoder) throws -> ViewItem {
///     try decoder.decode(
///       codingKey: Self.polymorphicMetaCodingKey,
///       matchingTypes: [
///         ImageViewItem.self,
///         TextViewItem.self,
///       ],
///       fallbackType: UndefinedViewItem.self
///     )
///   }
/// }
///
/// @PolymorphicValue<ViewItemCodableStrategy>
/// var item: ViewItem
/// ```
///
/// Example usage (with `@PolymorphicCodableStrategyProviding` macro):
/// ```swift
/// @PolymorphicCodableStrategyProviding(
///   identifierCodingKey: "type",
///   matchingTypes: [
///     ImageViewItem.self,
///     TextViewItem.self,
///   ],
///   fallbackType: UndefinedViewItem.self
/// )
/// protocol ViewItem: Codable {
///   var id: String { get }
/// }
///
/// @PolymorphicValue<ViewItemCodableStrategy>
/// var item: ViewItem
public protocol PolymorphicCodableStrategy {
  associatedtype ExpectedType
  static var polymorphicMetaCodingKey: CodingKey { get }
  static func decode(from decoder: Decoder) throws -> ExpectedType
}
