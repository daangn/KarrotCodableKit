//
//  UnnestedPolymorphicDecodableMacroTests 2.swift
//  KarrotDecodableKit
//
//  Created by elon on 6/11/25.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(KarrotCodableKitMacros)
import KarrotCodableKitMacros
#endif

final class UnnestedPolymorphicDecodableMacroTests: XCTestCase {

  #if canImport(KarrotCodableKitMacros)
  let testMacros: [String: Macro.Type] = [
    "UnnestedPolymorphicDecodable": UnnestedPolymorphicDecodableMacro.self,
  ]
  #endif

  func testUnnestedPolymorphicDecodableMacroExpansion() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicDecodable(
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
            case data
          }

          private enum NestedDataCodingKeys: String, CodingKey {
            case id
            case title
          }
        }

        extension TitleViewItem: PolymorphicDecodableType {
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
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testUnnestedPolymorphicDecodableMacroWithSnakeCaseKeys() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicDecodable(
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
            case data
          }

          private enum NestedDataCodingKeys: String, CodingKey {
            case id
            case itemTitle = "item_title"
          }
        }

        extension TitleViewItem: PolymorphicDecodableType {
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
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testUnnestedPolymorphicDecodableMacroWithoutProperties() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicDecodable(
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
            case some_data
          }

          private enum NestedDataCodingKeys: CodingKey {
          }

        }

        extension TitleViewItem: PolymorphicDecodableType {
          static var polymorphicIdentifier: String {
            "TITLE_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {

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
