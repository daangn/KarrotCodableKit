//
//  CustomDecodableMacroTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 4/16/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(KarrotCodableKitMacros)
import KarrotCodableKitMacros
#endif

final class CustomDecodableMacroTests: XCTestCase {

  #if canImport(KarrotCodableKitMacros)
  let testMacros: [String: Macro.Type] = [
    "CustomDecodable": CustomDecodableMacro.self,
    "CodableKey": CodableKeyMacro.self,
  ]
  #endif

  func testExpansionAddsDefaultSnakeCaseCodingKeys() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomDecodable(codingKeyStyle: .snakeCase)
      struct Person {
        let name: String
        let userProfileURL: String
      }
      """,
      expandedSource: """
        struct Person {
          let name: String
          let userProfileURL: String

          private enum CodingKeys: String, CodingKey {
            case `name`
            case `userProfileURL` = "user_profile_url"
          }
        }

        extension Person: Decodable {
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testExpansionAddsNoneSnakeCaseCodingKeys() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomDecodable(codingKeyStyle: .default)
      struct Person {
        let name: String
        let userProfileUrl: String
      }
      """,
      expandedSource: """
        struct Person {
          let name: String
          let userProfileUrl: String

          private enum CodingKeys: String, CodingKey {
            case `name`
            case `userProfileUrl`
          }
        }

        extension Person: Decodable {
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

// MARK: - Nested Decodable

extension CustomDecodableMacroTests {
  func testExpansionAddsWithNestedDecodable() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomDecodable(codingKeyStyle: .snakeCase)
      struct Person {
        @CustomDecodable(codingKeyStyle: .snakeCase)
        struct NestedStruct {
          let propertyWithSameName: Bool
        }

        let nestedStructProperty: NestedStruct
      }
      """,
      expandedSource: """
        struct Person {
          struct NestedStruct {
            let propertyWithSameName: Bool

            private enum CodingKeys: String, CodingKey {
              case `propertyWithSameName` = "property_with_same_name"
            }
          }

          let nestedStructProperty: NestedStruct

          private enum CodingKeys: String, CodingKey {
            case `nestedStructProperty` = "nested_struct_property"
          }
        }

        extension Person.NestedStruct: Decodable {
        }

        extension Person: Decodable {
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testExpansionAddsWithExtensionNestedDecodable() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomDecodable(codingKeyStyle: .default)
      struct Person {
        let nestedStructProperty: NestedStruct
      }

      extension Person {
        @CustomDecodable(codingKeyStyle: .snakeCase)
        struct NestedStruct {
          let propertyWithSameName: Bool
        }
      }
      """,
      expandedSource: """
        struct Person {
          let nestedStructProperty: NestedStruct

          private enum CodingKeys: String, CodingKey {
            case `nestedStructProperty`
          }
        }

        extension Person {
          struct NestedStruct {
            let propertyWithSameName: Bool

            private enum CodingKeys: String, CodingKey {
              case `propertyWithSameName` = "property_with_same_name"
            }
          }
        }

        extension Person: Decodable {
        }

        extension Person.NestedStruct: Decodable {
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

// MARK: - CodableKey

extension CustomDecodableMacroTests {
  func testExpansionWithCodableKeyAddsCodingKeys() {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @CustomDecodable(codingKeyStyle: .snakeCase)
      struct Person {
        let name: String
        let userAge: Int
        @CodableKey(name: "userProfileUrl") let userProfileURL: String

        func randomFunction() {}
      }
      """,
      // when
      expandedSource: """
        struct Person {
          let name: String
          let userAge: Int
          let userProfileURL: String

          func randomFunction() {}

          private enum CodingKeys: String, CodingKey {
            case `name`
            case `userAge` = "user_age"
            case `userProfileURL` = "userProfileUrl"
          }
        }

        extension Person: Decodable {
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testExpansionWithComputedPropertyCodingKeys() {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @CustomDecodable(codingKeyStyle: .snakeCase)
      struct Person {
        let name: String
        let userAge: Int
        @CodableKey(name: "userProfileUrl") let userProfileURL: String

        var id: String { "1234" }

        func randomFunction() {}
      }
      """,
      // when
      expandedSource: """
        struct Person {
          let name: String
          let userAge: Int
          let userProfileURL: String

          var id: String { "1234" }

          func randomFunction() {}

          private enum CodingKeys: String, CodingKey {
            case `name`
            case `userAge` = "user_age"
            case `userProfileURL` = "userProfileUrl"
          }
        }

        extension Person: Decodable {
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

// MARK: - cannotApplyToEnum

extension CustomDecodableMacroTests {
  func testDecodableExpansionToEnum() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomDecodable(codingKeyStyle: .snakeCase)
      enum Test {
        case foo
        case bar
      }
      """,
      expandedSource: """
        enum Test {
          case foo
          case bar
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "`@CustomCodable`, `@CustomEncodable`, `@CustomDecodable` cannot be applied to enum",
          line: 1,
          column: 1
        ),
        DiagnosticSpec(
          message: "`@CustomCodable`, `@CustomEncodable`, `@CustomDecodable` cannot be applied to enum",
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
