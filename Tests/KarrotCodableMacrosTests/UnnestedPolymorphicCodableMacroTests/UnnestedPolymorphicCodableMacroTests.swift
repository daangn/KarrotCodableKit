//
//  UnnestedPolymorphicCodableMacroTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 6/10/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(KarrotCodableKitMacros)
import KarrotCodableKitMacros
#endif

final class UnnestedPolymorphicCodableMacroTests: XCTestCase {

  #if canImport(KarrotCodableKitMacros)
  let testMacros: [String: Macro.Type] = [
    "UnnestedPolymorphicCodable": UnnestedPolymorphicCodableMacro.self,
  ]
  #endif

  func testUnnestedPolymorphicCodableMacroExpansion() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicCodable(
        identifier: "TITLE_VIEW_ITEM",
        forKey: "data"
      )
      struct TitleViewItem: ViewItem {
        let id: String
        let title: String?
      }
      """,
      expandedSource: """
        struct TitleViewItem: ViewItem {
          let id: String
          let title: String?

          private enum CodingKeys: String, CodingKey {
            case `data`
          }

          private enum NestedDataCodingKeys: String, CodingKey {
            case `id`
            case `title`
          }
        }

        extension TitleViewItem: PolymorphicCodableType {
          static var polymorphicIdentifier: String {
            "TITLE_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dataContainer = try container.nestedContainer(
              keyedBy: NestedDataCodingKeys.self,
              forKey: CodingKeys.data
            )

            self.id = try dataContainer.decode(String.self, forKey: NestedDataCodingKeys.id)
            self.title = try dataContainer.decode(String?.self, forKey: NestedDataCodingKeys.title)
          }

          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            var dataContainer = container.nestedContainer(
              keyedBy: NestedDataCodingKeys.self,
              forKey: CodingKeys.data
            )

            try dataContainer.encode(id, forKey: NestedDataCodingKeys.id)
            try dataContainer.encode(title, forKey: NestedDataCodingKeys.title)
          }
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testUnnestedPolymorphicCodableMacroWithSnakeCaseKeys() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicCodable(
        identifier: "TITLE_VIEW_ITEM",
        forKey: "data",
        codingKeyStyle: .snakeCase
      )
      struct TitleViewItem: ViewItem {
        let id: String
        let itemTitle: String?
      }
      """,
      expandedSource: """
        struct TitleViewItem: ViewItem {
          let id: String
          let itemTitle: String?

          private enum CodingKeys: String, CodingKey {
            case `data`
          }

          private enum NestedDataCodingKeys: String, CodingKey {
            case `id`
            case `itemTitle` = "item_title"
          }
        }

        extension TitleViewItem: PolymorphicCodableType {
          static var polymorphicIdentifier: String {
            "TITLE_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dataContainer = try container.nestedContainer(
              keyedBy: NestedDataCodingKeys.self,
              forKey: CodingKeys.data
            )

            self.id = try dataContainer.decode(String.self, forKey: NestedDataCodingKeys.id)
            self.itemTitle = try dataContainer.decode(String?.self, forKey: NestedDataCodingKeys.itemTitle)
          }

          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            var dataContainer = container.nestedContainer(
              keyedBy: NestedDataCodingKeys.self,
              forKey: CodingKeys.data
            )

            try dataContainer.encode(id, forKey: NestedDataCodingKeys.id)
            try dataContainer.encode(itemTitle, forKey: NestedDataCodingKeys.itemTitle)
          }
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testUnnestedPolymorphicCodableMacroWithoutProperties() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicCodable(
        identifier: "TITLE_VIEW_ITEM",
        forKey: "some_data",
        codingKeyStyle: .snakeCase
      )
      struct TitleViewItem: ViewItem {

      }
      """,
      expandedSource: """
        struct TitleViewItem: ViewItem {

          private enum CodingKeys: String, CodingKey {
            case `some_data`
          }

          private enum NestedDataCodingKeys: CodingKey {
          }

        }

        extension TitleViewItem: PolymorphicCodableType {
          static var polymorphicIdentifier: String {
            "TITLE_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {

          }

          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            _ = container.nestedContainer(
              keyedBy: NestedDataCodingKeys.self,
              forKey: CodingKeys.some_data
            )
          }
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testUnnestedPolymorphicCodableMacroWithBacktickedProperties() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicCodable(
        identifier: "SPECIAL_VIEW_ITEM",
        forKey: "data"
      )
      struct SpecialViewItem: ViewItem {
        let id: String
        let `class`: String
        let `private`: String?
      }
      """,
      expandedSource: """
        struct SpecialViewItem: ViewItem {
          let id: String
          let `class`: String
          let `private`: String?

          private enum CodingKeys: String, CodingKey {
            case `data`
          }

          private enum NestedDataCodingKeys: String, CodingKey {
            case `id`
            case `class`
            case `private`
          }
        }

        extension SpecialViewItem: PolymorphicCodableType {
          static var polymorphicIdentifier: String {
            "SPECIAL_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dataContainer = try container.nestedContainer(
              keyedBy: NestedDataCodingKeys.self,
              forKey: CodingKeys.data
            )

            self.id = try dataContainer.decode(String.self, forKey: NestedDataCodingKeys.id)
            self.`class` = try dataContainer.decode(String.self, forKey: NestedDataCodingKeys.`class`)
            self.`private` = try dataContainer.decode(String?.self, forKey: NestedDataCodingKeys.`private`)
          }

          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            var dataContainer = container.nestedContainer(
              keyedBy: NestedDataCodingKeys.self,
              forKey: CodingKeys.data
            )

            try dataContainer.encode(id, forKey: NestedDataCodingKeys.id)
            try dataContainer.encode(`class`, forKey: NestedDataCodingKeys.`class`)
            try dataContainer.encode(`private`, forKey: NestedDataCodingKeys.`private`)
          }
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
}
