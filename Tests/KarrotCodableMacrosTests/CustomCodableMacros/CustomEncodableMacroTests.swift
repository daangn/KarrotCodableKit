//
//  CustomEncodableMacroTests.swift
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

final class CustomEncodableMacroTests: XCTestCase {

  #if canImport(KarrotCodableKitMacros)
  let testMacros: [String: Macro.Type] = [
    "CustomEncodable": CustomEncodableMacro.self,
    "CodableKey": CodableKeyMacro.self,
  ]
  #endif

  func testExpansionAddsDefaultSnakeCaseCodingKeys() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomEncodable(codingKeyStyle: .snakeCase)
      struct Person {
        let name: String
        let userProfileURL: String
      }
      """,
      expandedSource: """
        struct Person {
          let name: String
          let userProfileURL: String

          enum CodingKeys: String, CodingKey {
            case name
            case userProfileURL = "user_profile_url"
          }
        }

        extension Person: Encodable {
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
      @CustomEncodable(codingKeyStyle: .default)
      struct Person {
        let name: String
        let userProfileUrl: String
      }
      """,
      expandedSource: """
        struct Person {
          let name: String
          let userProfileUrl: String

          enum CodingKeys: String, CodingKey {
            case name
            case userProfileUrl
          }
        }

        extension Person: Encodable {
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


// MARK: - Nested Encodable

extension CustomEncodableMacroTests {
  func testExpansionAddsWithNestedEncodable() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomEncodable(codingKeyStyle: .snakeCase)
      struct Person {
        @CustomEncodable(codingKeyStyle: .snakeCase)
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

            enum CodingKeys: String, CodingKey {
              case propertyWithSameName = "property_with_same_name"
            }
          }

          let nestedStructProperty: NestedStruct

          enum CodingKeys: String, CodingKey {
            case nestedStructProperty = "nested_struct_property"
          }
        }

        extension Person.NestedStruct: Encodable {
        }

        extension Person: Encodable {
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testExpansionAddsWithExtensionNestedEncodable() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomEncodable(codingKeyStyle: .default)
      struct Person {
        let nestedStructProperty: NestedStruct
      }

      extension Person {
        @CustomEncodable(codingKeyStyle: .snakeCase)
        struct NestedStruct {
          let propertyWithSameName: Bool
        }
      }
      """,
      expandedSource: """
        struct Person {
          let nestedStructProperty: NestedStruct

          enum CodingKeys: String, CodingKey {
            case nestedStructProperty
          }
        }

        extension Person {
          struct NestedStruct {
            let propertyWithSameName: Bool

            enum CodingKeys: String, CodingKey {
              case propertyWithSameName = "property_with_same_name"
            }
          }
        }

        extension Person: Encodable {
        }

        extension Person.NestedStruct: Encodable {
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

extension CustomEncodableMacroTests {
  func testExpansionWithCodableKeyAddsCodingKeys() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomEncodable(codingKeyStyle: .snakeCase)
      struct Person {
        let name: String
        let userAge: Int
        @CodableKey(name: "userProfileUrl") let userProfileURL: String

        func randomFunction() {}
      }
      """,
      expandedSource: """
        struct Person {
          let name: String
          let userAge: Int
          let userProfileURL: String

          func randomFunction() {}

          enum CodingKeys: String, CodingKey {
            case name
            case userAge = "user_age"
            case userProfileURL = "userProfileUrl"
          }
        }

        extension Person: Encodable {
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
    assertMacroExpansion(
      """
      @CustomEncodable(codingKeyStyle: .snakeCase)
      struct Person {
        let name: String
        let userAge: Int
        @CodableKey(name: "userProfileUrl") let userProfileURL: String

        var id: String { "1234" }

        func randomFunction() {}
      }
      """,
      expandedSource: """
        struct Person {
          let name: String
          let userAge: Int
          let userProfileURL: String

          var id: String { "1234" }

          func randomFunction() {}

          enum CodingKeys: String, CodingKey {
            case name
            case userAge = "user_age"
            case userProfileURL = "userProfileUrl"
          }
        }

        extension Person: Encodable {
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

extension CustomEncodableMacroTests {
  func testEncodableExpansionToEnum() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomEncodable(codingKeyStyle: .snakeCase)
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
        )
      ],
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
}
