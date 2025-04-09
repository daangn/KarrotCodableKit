//
//  CustomCodableMacroTests.swift
//  KarrotCodableKit
//
//  Created by Elon on 10/10/23.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(KarrotCodableKitMacros)
import KarrotCodableKitMacros
#endif

final class CustomCodableMacroTests: XCTestCase {

  #if canImport(KarrotCodableKitMacros)
  let testMacros: [String: Macro.Type] = [
    "CustomCodable": CustomCodableMacro.self,
    "CodableKey": CodableKeyMacro.self,
  ]
  #endif

  func testExpansionAddsDefaultSnakeCaseCodingKeys() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomCodable(codingKeyStyle: .snakeCase)
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

        extension Person: Codable {
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
      @CustomCodable(codingKeyStyle: .default)
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

        extension Person: Codable {
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


// MARK: - Nested Codable

extension CustomCodableMacroTests {
  func testExpansionAddsWithNestedCodable() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomCodable(codingKeyStyle: .snakeCase)
      struct Person {
        @CustomCodable(codingKeyStyle: .snakeCase)
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

        extension Person.NestedStruct: Codable {
        }

        extension Person: Codable {
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testExpansionAddsWithExtensionNestedCodable() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomCodable
      struct Person {
        let nestedStructProperty: NestedStruct
      }

      extension Person {
        @CustomCodable(codingKeyStyle: .snakeCase)
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

        extension Person: Codable {
        }

        extension Person.NestedStruct: Codable {
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

extension CustomCodableMacroTests {
  func testExpansionWithCodableKeyAddsCodingKeys() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomCodable(codingKeyStyle: .snakeCase)
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

        extension Person: Codable {
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
      @CustomCodable(codingKeyStyle: .snakeCase)
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

        extension Person: Codable {
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

extension CustomCodableMacroTests {
  func testCodableExpansionToEnum() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @CustomCodable(codingKeyStyle: .snakeCase)
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
