//
//  PolymorphicIdentifiable.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A protocol defining a requirement for a unique static identifier used in polymorphic decoding.
///
/// Conforming types must provide a static `polymorphicIdentifier` string. This identifier allows
/// a `PolymorphicCodableStrategy` (often generated by `@PolymorphicCodableStrategyProviding`)
/// to map a type identifier found in JSON data (e.g., a "type" field) back to the corresponding Swift type
/// during decoding.
///
/// ```swift
/// // Example usage with @PolymorphicCodable:
/// @PolymorphicCodable(identifier: "image_item")
/// struct ImageItem: ViewItem { // Assumes ViewItem conforms to Decodable
///   let url: URL
/// }
///
/// // The @PolymorphicCodable macro automatically generates:
/// // extension ImageItem: PolymorphicIdentifiable {
/// //   static var polymorphicIdentifier: String { "image_item" }
/// // }
/// ```
public protocol PolymorphicIdentifiable {
  /// A unique static string identifier for the conforming type.
  /// This is typically used to match against a type identifier field in JSON during polymorphic decoding.
  static var polymorphicIdentifier: String { get }
}

public typealias PolymorphicCodableType = Codable & PolymorphicIdentifiable
public typealias PolymorphicEncodableType = Encodable & PolymorphicIdentifiable
public typealias PolymorphicDecodableType = Decodable & PolymorphicIdentifiable
