//
//  PolymorphicEnumEncodableMacroTests.swift
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

final class PolymorphicEnumEncodableMacroTests: XCTestCase {

  #if canImport(KarrotCodableKitMacros)
  let testMacros: [String: Macro.Type] = [
    "PolymorphicEnumEncodable": PolymorphicEnumEncodableMacro.self,
  ]
  #endif

  func testPolymorphicEnumEncodableMacro() throws {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @PolymorphicEnumEncodable(identifierCodingKey: "type")
      public enum CalloutBadge {
        case callout(DummyCallout)
        case actionableCallout(DummyActionableCallout)
        case dismissibleCallout(value: DummyDismissibleCallout)
      }
      """,
      // when
      expandedSource: """

        public enum CalloutBadge {
          case callout(DummyCallout)
          case actionableCallout(DummyActionableCallout)
          case dismissibleCallout(value: DummyDismissibleCallout)
        }

        extension CalloutBadge: Encodable {
          public func encode(to encoder: any Encoder) throws {
            switch self {
            case .callout(let value):
              try value.encode(to: encoder)
             case .actionableCallout(let value):
              try value.encode(to: encoder)
             case .dismissibleCallout(let value):
              try value.encode(to: encoder)
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

  func testPolymorphicEnumEncodableMacroWithDefaultParameters() throws {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @PolymorphicEnumEncodable
      public enum CalloutBadge {
        case callout(DummyCallout)
        case actionableCallout(DummyActionableCallout)
        case dismissibleCallout(value: DummyDismissibleCallout)
      }
      """,
      // when
      expandedSource: """

        public enum CalloutBadge {
          case callout(DummyCallout)
          case actionableCallout(DummyActionableCallout)
          case dismissibleCallout(value: DummyDismissibleCallout)
        }

        extension CalloutBadge: Encodable {
          public func encode(to encoder: any Encoder) throws {
            switch self {
            case .callout(let value):
              try value.encode(to: encoder)
             case .actionableCallout(let value):
              try value.encode(to: encoder)
             case .dismissibleCallout(let value):
              try value.encode(to: encoder)
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

  func testPolymorphicEnumEncodableMacroTypeError() {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @PolymorphicEnumEncodable(identifierCodingKey: "test")
      struct CalloutBadge {
        let callout: DummyCallout
        let actionableCallout: DummyActionableCallout
        let dismissibleCallout: DummyDismissibleCallout
      }
      """,
      // when
      expandedSource: """
        struct CalloutBadge {
          let callout: DummyCallout
          let actionableCallout: DummyActionableCallout
          let dismissibleCallout: DummyDismissibleCallout
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "`@PolymorphicEnumEncodable` can only be attached to enums",
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

  func testPolymorphicEnumEncodableMacroIdentifierValueError() {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @PolymorphicEnumEncodable(identifierCodingKey: "")
      enum CalloutBadge {
        case callout(DummyCallout)
        case actionableCallout(DummyActionableCallout)
        case dismissibleCallout(DummyDismissibleCallout)
      }
      """,
      // when
      expandedSource: """
        enum CalloutBadge {
          case callout(DummyCallout)
          case actionableCallout(DummyActionableCallout)
          case dismissibleCallout(DummyDismissibleCallout)
        }
        """,
      diagnostics: [
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

  func testPolymorphicEnumEncodableMacroAssociatedValueCountError() {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @PolymorphicEnumEncodable(identifierCodingKey: "type")
      enum CalloutBadge {
        case callout(DummyCallout, String)
        case actionableCallout(DummyActionableCallout)
        case dismissibleCallout(DummyDismissibleCallout)
      }
      """,
      // when
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
        ),
      ],
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testPolymorphicEnumEncodableMacroMissingAssociatedValueError() {
    #if canImport(KarrotCodableKitMacros)
    // given
    assertMacroExpansion(
      """
      @PolymorphicEnumEncodable(identifierCodingKey: "type")
      enum CalloutBadge {
        case callout
        case actionableCallout(DummyActionableCallout)
        case dismissibleCallout(DummyDismissibleCallout)
      }
      """,
      // when
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
