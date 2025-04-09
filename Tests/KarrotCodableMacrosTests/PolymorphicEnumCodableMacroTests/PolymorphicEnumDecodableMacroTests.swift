//
//  PolymorphicEnumDecodableMacroTests.swift
//
//
//  Created by Elon on 10/21/24.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(KarrotCodableKitMacros)
import KarrotCodableKitMacros
#endif

final class PolymorphicEnumDecodableMacroTests: XCTestCase {

  #if canImport(KarrotCodableKitMacros)
  let testMacros: [String: Macro.Type] = [
    "PolymorphicEnumDecodable": PolymorphicEnumDecodableMacro.self,
  ]
  #endif

  func testPolymorphicEnumDecodableMacro() throws {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @PolymorphicEnumDecodable(identifierCodingKey: "type")
      public enum CalloutBadge {
        case callout(DummyCallout)
        case actionableCallout(DummyActionableCallout)
        case dismissibleCallout(value: DummyDismissibleCallout)
      }
      """,
      expandedSource: """

        public enum CalloutBadge {
          case callout(DummyCallout)
          case actionableCallout(DummyActionableCallout)
          case dismissibleCallout(value: DummyDismissibleCallout)
        }

        extension CalloutBadge: Decodable {
          enum PolymorphicMetaCodingKey: CodingKey {
            case type
          }

          public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: PolymorphicMetaCodingKey.self)
            let type = try container.decode(String.self, forKey: PolymorphicMetaCodingKey.type)

            switch type {
            case DummyCallout.polymorphicIdentifier:
              self = .callout(try DummyCallout(from: decoder))
             case DummyActionableCallout.polymorphicIdentifier:
              self = .actionableCallout(try DummyActionableCallout(from: decoder))
             case DummyDismissibleCallout.polymorphicIdentifier:
              self = .dismissibleCallout(value: try DummyDismissibleCallout(from: decoder))
            default:
              throw PolymorphicCodableError.unableToFindPolymorphicType(type)
            }
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

  func testPolymorphicEnumDecodableMacroTypeError() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @PolymorphicEnumDecodable(identifierCodingKey: "test")
      struct CalloutBadge {
        let callout: DummyCallout
        let actionableCallout: DummyActionableCallout
        let dismissibleCallout: DummyDismissibleCallout
      }
      """,
      expandedSource: """
        struct CalloutBadge {
          let callout: DummyCallout
          let actionableCallout: DummyActionableCallout
          let dismissibleCallout: DummyDismissibleCallout
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "`@PolymorphicEnumDecodable` can only be attached to enums",
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

  func testPolymorphicEnumDecodableMacroIdentifierValueError() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @PolymorphicEnumDecodable(identifierCodingKey: "")
      enum CalloutBadge {
        case callout(DummyCallout)
        case actionableCallout(DummyActionableCallout)
        case dismissibleCallout(DummyDismissibleCallout)
      }
      """,
      expandedSource: """
        enum CalloutBadge {
          case callout(DummyCallout)
          case actionableCallout(DummyActionableCallout)
          case dismissibleCallout(DummyDismissibleCallout)
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Invalid or missing polymorphic identifier: expected a non-empty string.",
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

  func testPolymorphicEnumDecodableMacroAssociatedValueCountError() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @PolymorphicEnumDecodable(identifierCodingKey: "type")
      enum CalloutBadge {
        case callout(DummyCallout, String)
        case actionableCallout(DummyActionableCallout)
        case dismissibleCallout(DummyDismissibleCallout)
      }
      """,
      expandedSource: """
        enum CalloutBadge {
          case callout(DummyCallout, String)
          case actionableCallout(DummyActionableCallout)
          case dismissibleCallout(DummyDismissibleCallout)
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Polymorphic Enum cases can only have one associated value",
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

  func testPolymorphicEnumDecodableMacroMissingAssociatedValueError() {
    #if canImport(KarrotCodableKitMacros)
    assertMacroExpansion(
      """
      @PolymorphicEnumDecodable(identifierCodingKey: "type")
      enum CalloutBadge {
        case callout
        case actionableCallout(DummyActionableCallout)
        case dismissibleCallout(DummyDismissibleCallout)
      }
      """,
      expandedSource: """
        enum CalloutBadge {
          case callout
          case actionableCallout(DummyActionableCallout)
          case dismissibleCallout(DummyDismissibleCallout)
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "Polymorphic Enum cases should have one associated value",
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
