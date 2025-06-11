//
//  UnnestedPolymorphicCodable.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/9/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation

/// A macro that enables polymorphic coding support by flattening nested JSON data structures.
///
/// This macro automatically implements the necessary components for polymorphic
/// encoding and decoding by adding PolymorphicCodableType conformance and generating
/// appropriate CodingKeys. Unlike the standard @PolymorphicCodable, this macro
/// removes the need for nested object, allowing you to declare properties directly
/// at the top level instead of wrapping them in a separate nested struct.
///
/// The macro generates two separate CodingKeys enums:
/// - `CodingKeys`: For top-level keys including "type" and the specified nested key
/// - `NestedDataCodingKeys`: For properties within the nested data object
///
/// It also generates custom `init(from decoder:)` and `encode(to encoder:)` methods
/// that handle the unnesting process automatically.
///
/// For example, given JSON:
/// ```json
/// {
///   "type": "TITLE_VIEW_ITEM",
///   "data": {
///     "id": "1e243b34-b8a6-41c8-b08f-cba8d014021f",
///     "title": "Hello, world!"
///   }
/// }
/// ```
///
/// You can declare:
/// ```swift
/// @UnnestedPolymorphicCodable(
///    identifier: "TITLE_VIEW_ITEM",
///    forKey: "data"
/// )
/// struct TitleViewItem: ViewItem {
///   let id: String
///   let title: String
/// }
///
/// @PolymorphicCodableStrategyProviding(
///   identifierCodingKey: "type",
///   matchingTypes: [
///     TitleViewItem.self,
///   ]
/// )
/// protocol ViewItem: Codable {
///   var id: String { get }
/// }
/// ```
///
/// Instead of having to create a separate nested struct for the "data" content.
///
/// - Parameters:
///   - identifier: The string value used to identify this specific type in polymorphic coding.
///   - forKey: The key name in the JSON that contains the nested object to be unnested.
///   - codingKeyStyle: Specifies the naming convention to use when generating `NestedDataCodingKeys`.
///    Default is `.default` which preserves the original property names. When set to `.snakeCase`,
///    property names will be converted to snake_case format.
@attached(
  extension,
  conformances: PolymorphicCodableType,
  names: named(polymorphicIdentifier),
  named(init),
  named(encode)
)
@attached(member, names: named(CodingKeys), named(NestedDataCodingKeys))
public macro UnnestedPolymorphicCodable(
  identifier: String,
  forKey nestedKey: String,
  codingKeyStyle: CodingKeyStyle = .default
) = #externalMacro(module: "KarrotCodableKitMacros", type: "UnnestedPolymorphicCodableMacro")
