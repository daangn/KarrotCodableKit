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

          @CustomDecodable
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

        extension TitleViewItem: PolymorphicDecodableType {
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
        forKey: "item",
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
            case `item`
          }

          @CustomDecodable(codingKeyStyle: .snakeCase)
          fileprivate struct __NestedDataStruct {
            let id: String
            let itemTitle: String?
          }
        }

        extension TitleViewItem: PolymorphicDecodableType {
          static var polymorphicIdentifier: String {
            "TITLE_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dataContainer = try container.decode(__NestedDataStruct.self, forKey: CodingKeys.item)

            self.id = dataContainer.id
            self.itemTitle = dataContainer.itemTitle
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
            case `some_data`
          }

          @CustomDecodable(codingKeyStyle: .snakeCase)
          fileprivate struct __NestedDataStruct {
          }

        }

        extension TitleViewItem: PolymorphicDecodableType {
          static var polymorphicIdentifier: String {
            "TITLE_VIEW_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            _ = try container.decode(__NestedDataStruct.self, forKey: CodingKeys.some_data)
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

  func testUnnestedPolymorphicDecodableMacroWithBacktickedProperties() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicDecodable(
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

          @CustomDecodable
          fileprivate struct __NestedDataStruct {
            let id: String
            let `class`: String
            let `private`: String?
          }
        }

        extension SpecialViewItem: PolymorphicDecodableType {
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
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testUnnestedPolymorphicDecodableMacroAppliedToEnum() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicDecodable(
        identifier: "ENUM_ITEM",
        forKey: "data"
      )
      enum SomeEnum {
        case first
        case second(String)
      }
      """,
      expandedSource: """
        enum SomeEnum {
          case first
          case second(String)
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "`@UnnestedPolymorphicDecodable` cannot be applied to enum types. Use `@PolymorphicEnumDecodable` instead.",
          line: 1,
          column: 1
        ),
        DiagnosticSpec(
          message: "`@UnnestedPolymorphicDecodable` cannot be applied to enum types. Use `@PolymorphicEnumDecodable` instead.",
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

  func testUnnestedPolymorphicDecodableMacroWithEmptyIdentifier() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicDecodable(
        identifier: "",
        forKey: "data"
      )
      struct TestItem: ViewItem {
        let id: String
      }
      """,
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

  func testUnnestedPolymorphicDecodableMacroWithConstantInitializedProperties() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicDecodable(
        identifier: "CONST_ITEM",
        forKey: "data"
      )
      struct ConstantItem: ViewItem {
        let id: String
        let constantWithValue: String = "defaultValue"
        var mutableProperty: String = "initialValue"
      }
      """,
      expandedSource: """
        struct ConstantItem: ViewItem {
          let id: String
          let constantWithValue: String = "defaultValue"
          var mutableProperty: String = "initialValue"

          private enum CodingKeys: String, CodingKey {
            case `data`
          }

          @CustomDecodable
          fileprivate struct __NestedDataStruct {
            let id: String
            let constantWithValue: String = "defaultValue"
            var mutableProperty: String = "initialValue"
          }
        }

        extension ConstantItem: PolymorphicDecodableType {
          static var polymorphicIdentifier: String {
            "CONST_ITEM"
          }

          init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let dataContainer = try container.decode(__NestedDataStruct.self, forKey: CodingKeys.data)

            self.id = dataContainer.id
            self.mutableProperty = dataContainer.mutableProperty
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

  func testUnnestedPolymorphicDecodableMacroWithEmptyKey() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @UnnestedPolymorphicDecodable(
        identifier: "VIEW_ITEM",
        forKey: ""
      )
      struct TestItem: ViewItem {
        let id: String
      }
      """,
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
