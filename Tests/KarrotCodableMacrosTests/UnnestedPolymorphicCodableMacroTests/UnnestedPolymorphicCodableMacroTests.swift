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
    // given
    assertMacroExpansion(
      """
      @UnnestedPolymorphicCodable(
        identifier: "TITLE_VIEW_ITEM",
        forKey: "data"
      )
      struct TitleViewItem: ViewItem {
        let id: String
        let title: String?
        @CodableKey(name: "uri")
        let url: URL?
        var someProperty: String? = "someValue"
        var intValue: Int
        var doubleValue = 1.1
        var computedProperty: String {
          "computedValue"
        }
        static let staticValue = true
      }
      """,
      // when
      expandedSource: """
        struct TitleViewItem: ViewItem {
          let id: String
          let title: String?
          @CodableKey(name: "uri")
          let url: URL?
          var someProperty: String? = "someValue"
          var intValue: Int
          var doubleValue = 1.1
          var computedProperty: String {
            "computedValue"
          }
          static let staticValue = true

          private enum CodingKeys: String, CodingKey {
            case `data`
          }

          @CustomCodable
          fileprivate struct __NestedDataStruct {
            let id: String
            let title: String?
            @CodableKey(name: "uri")
            let url: URL?
            var someProperty: String? = "someValue"
            var intValue: Int
            var doubleValue = 1.1
          }
        }

        extension TitleViewItem: PolymorphicCodableType {
          static var polymorphicIdentifier: String {
            "TITLE_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dataContainer = try container.decode(__NestedDataStruct.self, forKey: CodingKeys.data)

            self.id = dataContainer.id
            self.title = dataContainer.title
            self.url = dataContainer.url
            self.someProperty = dataContainer.someProperty
            self.intValue = dataContainer.intValue
            self.doubleValue = dataContainer.doubleValue
          }

          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(
              __NestedDataStruct(
                id: id,
                title: title,
                url: url,
                someProperty: someProperty,
                intValue: intValue,
                doubleValue: doubleValue
              ),
              forKey: CodingKeys.data
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

  func testUnnestedPolymorphicCodableMacroWithSnakeCaseKeys() throws {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @UnnestedPolymorphicCodable(
        identifier: "TITLE_VIEW_ITEM",
        forKey: "item",
        codingKeyStyle: .snakeCase
      )
      struct TitleViewItem: ViewItem {
        let id: String
        let itemTitle: String?
      }
      """,
      // when
      expandedSource: """
        struct TitleViewItem: ViewItem {
          let id: String
          let itemTitle: String?

          private enum CodingKeys: String, CodingKey {
            case `item`
          }

          @CustomCodable(codingKeyStyle: .snakeCase)
          fileprivate struct __NestedDataStruct {
            let id: String
            let itemTitle: String?
          }
        }

        extension TitleViewItem: PolymorphicCodableType {
          static var polymorphicIdentifier: String {
            "TITLE_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dataContainer = try container.decode(__NestedDataStruct.self, forKey: CodingKeys.item)

            self.id = dataContainer.id
            self.itemTitle = dataContainer.itemTitle
          }

          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(
              __NestedDataStruct(
                id: id,
                itemTitle: itemTitle
              ),
              forKey: CodingKeys.item
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

  func testUnnestedPolymorphicCodableMacroWithoutProperties() throws {
    #if canImport(KarrotCodableKitMacros)
    // given
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
      // when
      expandedSource: """
        struct TitleViewItem: ViewItem {

          private enum CodingKeys: String, CodingKey {
            case `some_data`
          }

          @CustomCodable(codingKeyStyle: .snakeCase)
          fileprivate struct __NestedDataStruct {
          }

        }

        extension TitleViewItem: PolymorphicCodableType {
          static var polymorphicIdentifier: String {
            "TITLE_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _ = try container.decode(__NestedDataStruct.self, forKey: CodingKeys.some_data)
          }

          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(
              __NestedDataStruct(),
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
    // given
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
      // when
      expandedSource: """
        struct SpecialViewItem: ViewItem {
          let id: String
          let `class`: String
          let `private`: String?

          private enum CodingKeys: String, CodingKey {
            case `data`
          }

          @CustomCodable
          fileprivate struct __NestedDataStruct {
            let id: String
            let `class`: String
            let `private`: String?
          }
        }

        extension SpecialViewItem: PolymorphicCodableType {
          static var polymorphicIdentifier: String {
            "SPECIAL_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dataContainer = try container.decode(__NestedDataStruct.self, forKey: CodingKeys.data)

            self.id = dataContainer.id
            self.`class` = dataContainer.`class`
            self.`private` = dataContainer.`private`
          }

          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(
              __NestedDataStruct(
                id: id,
                `class`: `class`,
                `private`: `private`
              ),
              forKey: CodingKeys.data
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

  func testUnnestedPolymorphicCodableMacroAppliedToEnum() throws {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @UnnestedPolymorphicCodable(
        identifier: "ENUM_ITEM",
        forKey: "data"
      )
      enum SomeEnum {
        case first
        case second(String)
      }
      """,
      // when
      expandedSource: """
        enum SomeEnum {
          case first
          case second(String)
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "`@UnnestedPolymorphicCodable` cannot be applied to enum types. Use `@PolymorphicEnumCodable` instead.",
          line: 1,
          column: 1
        ),
        DiagnosticSpec(
          message: "`@UnnestedPolymorphicCodable` cannot be applied to enum types. Use `@PolymorphicEnumCodable` instead.",
          line: 1,
          column: 1
        ),
      ],
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testUnnestedPolymorphicCodableMacroWithEmptyIdentifier() throws {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @UnnestedPolymorphicCodable(
        identifier: "",
        forKey: "data"
      )
      struct TestItem: ViewItem {
        let id: String
      }
      """,
      // when
      expandedSource: """
        struct TestItem: ViewItem {
          let id: String
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Invalid polymorphic identifier: expected a non-empty string.",
          line: 1,
          column: 1
        ),
        DiagnosticSpec(
          message: "Invalid polymorphic identifier: expected a non-empty string.",
          line: 1,
          column: 1
        ),
      ],
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testUnnestedPolymorphicCodableMacroWithConstantInitializedProperties() throws {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @UnnestedPolymorphicCodable(
        identifier: "CONST_ITEM",
        forKey: "data"
      )
      struct ConstantItem: ViewItem {
        let id: String
        let constantWithValue: String = "defaultValue"
        var mutableProperty: String = "initialValue"
      }
      """,
      // when
      expandedSource: """
        struct ConstantItem: ViewItem {
          let id: String
          let constantWithValue: String = "defaultValue"
          var mutableProperty: String = "initialValue"

          private enum CodingKeys: String, CodingKey {
            case `data`
          }

          @CustomCodable
          fileprivate struct __NestedDataStruct {
            let id: String
            let constantWithValue: String = "defaultValue"
            var mutableProperty: String = "initialValue"
          }
        }

        extension ConstantItem: PolymorphicCodableType {
          static var polymorphicIdentifier: String {
            "CONST_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dataContainer = try container.decode(__NestedDataStruct.self, forKey: CodingKeys.data)

            self.id = dataContainer.id
            self.mutableProperty = dataContainer.mutableProperty
          }

          func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(
              __NestedDataStruct(
                id: id,
                mutableProperty: mutableProperty
              ),
              forKey: CodingKeys.data
            )
          }
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Immutable property will not be decoded because it is declared with an initial value which cannot be overwritten",
          line: 7,
          column: 3,
          severity: .warning,
          fixIts: [
            FixItSpec(message: "Make the property mutable instead"),
          ]
        ),
      ],
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testUnnestedPolymorphicCodableMacroWithEmptyKey() throws {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @UnnestedPolymorphicCodable(
        identifier: "VIEW_ITEM",
        forKey: ""
      )
      struct TestItem: ViewItem {
        let id: String
      }
      """,
      // when
      expandedSource: """
        struct TestItem: ViewItem {
          let id: String
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Invalid nested key: expected a non-empty string.",
          line: 1,
          column: 1
        ),
        DiagnosticSpec(
          message: "Invalid nested key: expected a non-empty string.",
          line: 1,
          column: 1
        ),
      ],
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
}
