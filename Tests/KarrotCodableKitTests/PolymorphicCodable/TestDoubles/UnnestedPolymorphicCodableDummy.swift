//
//  UnnestedPolymorphicCodableDummy.swift
//  KarrotCodableKit
//
//  Created by elon on 6/10/25.
//

import Foundation

import KarrotCodableKit

// MARK: - Codable

struct DummyFeedResponse: Codable {
  @PolymorphicArrayValue<ViewItemCodableStrategy> var items: [ViewItem]
}

@UnnestedPolymorphicCodable(
  identifier: "TITLE_VIEW_ITEM",
  forKey: "data",
  codingKeyStyle: .snakeCase
)
struct TitleViewItem: ViewItem {
  let id: String
  let itemTitle: String?
}

@UnnestedPolymorphicCodable(
  identifier: "EMPTY_VIEW_ITEM",
  forKey: "data",
  codingKeyStyle: .snakeCase
)
struct EmptyViewItem: ViewItem {}

@UnnestedPolymorphicCodable(
  identifier: "SUBTITLE_VIEW_ITEM",
  forKey: "data"
)
struct SubtitleViewItem: ViewItem {
  let id: String
  let title: String

  @DefaultEmptyString
  private(set) var subtitle: String
}

@UnnestedPolymorphicCodable(
  identifier: "OPTIONAL_VIEW_ITEM",
  forKey: "data"
)
struct OptionalViewItem: ViewItem {
  let id: String
  let title: String?
  let count: Int?
  let url: URL?
}


// MARK: - Edge Case Test Structs

@UnnestedPolymorphicCodable(
  identifier: "CONSTANT_PROPERTY_VIEW_ITEM",
  forKey: "data"
)
struct ConstantPropertyViewItem: ViewItem {
  let id: String
  let constantString = "defaultValue"
  let constantInt = 42
  let title: String?
}

@UnnestedPolymorphicCodable(
  identifier: "COMPUTED_PROPERTY_VIEW_ITEM",
  forKey: "data"
)
struct ComputedPropertyViewItem: ViewItem {
  let id: String
  let title: String?

  var computedProperty: String {
    "computed"
  }

  var getOnlyProperty: Int { 42 }
}

@UnnestedPolymorphicCodable(
  identifier: "STATIC_PROPERTY_VIEW_ITEM",
  forKey: "data"
)
struct StaticPropertyViewItem: ViewItem {
  let id: String
  let title: String?
  static let staticConstant = "static"
  static var staticVariable = 100
}

@UnnestedPolymorphicCodable(
  identifier: "FUNCTION_VIEW_ITEM",
  forKey: "data"
)
struct FunctionViewItem: ViewItem {
  let id: String
  let title: String?

  func someFunction() -> String {
    "function"
  }

  mutating func mutatingFunction() {
    // do something
  }
}

@UnnestedPolymorphicCodable(
  identifier: "COMPLEX_TYPE_VIEW_ITEM",
  forKey: "data"
)
struct ComplexTypeViewItem: ViewItem {
  let id: String
  let tags: [String]
  let metadata: [String: String]?
  let nestedStruct: NestedStruct
  let optionalNestedStruct: NestedStruct?
}

struct NestedStruct: Codable {
  let name: String
  let value: Int
}
